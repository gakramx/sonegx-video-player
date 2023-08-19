#include "aes.h"
#include <QtAES/qaesencryption.h>
#include <QFile>
#include <QFileInfo>
#include <QCryptographicHash>
#include <QDebug>
AES::AES(QObject *parent)
    : QObject{parent}
{
    setoutputFullFilename(dir.path());
}
QVariant AES::encrypt(const QString& filePath, QByteArray key)
{
    QFile inputFile(filePath);
    if (!inputFile.open(QIODevice::ReadOnly))
    {
        // Handle file opening error
        return QVariant();
    }

    QByteArray plainText = inputFile.readAll();
    inputFile.close();

    QAESEncryption encryption(QAESEncryption::AES_128, QAESEncryption::ECB);
    QByteArray encodedText = encryption.encode(plainText, key);

    // Save the encrypted content to a new file
    QString encryptedFilePath = filePath + ".sgr";
    QFile outputFile(encryptedFilePath);
    if (!outputFile.open(QIODevice::WriteOnly))
    {
        // Handle file saving error
        return QVariant();
    }

    outputFile.write(encodedText);
    outputFile.close();
    qDebug()<<"encryp "<<encryptedFilePath;
    return QVariant::fromValue(encryptedFilePath);
}

QVariant AES::decrypt(const QString& filePath, QByteArray key)
{
    QUrl url(filePath);
    QString localName = url.isLocalFile() ? url.toLocalFile() : filePath;
    qDebug()<<"FILES : "<<localName;
    QFile inputFile(localName);
    QFileInfo fileInfo(inputFile);
    QString filepath=fileInfo.absolutePath();
    setinputPath(filepath);
    QString baseName = fileInfo.baseName();
    qDebug()<<"baseName : "<<baseName;
    if (!inputFile.open(QIODevice::ReadOnly))
    {
        // Handle file opening error
        return QVariant();
    }

    QByteArray encodedText = inputFile.readAll();
    inputFile.close();

    QAESEncryption encryption(QAESEncryption::AES_128, QAESEncryption::ECB);
    QByteArray decodedText = encryption.decode(encodedText, key);
    QString decodedString = QString(encryption.removePadding(decodedText));

    // Save the decrypted content to a new file
    QString _fullname = getoutputFullFilename();
    QString decryptedFilePath = _fullname + "/" + baseName;
    qDebug()<<"decryptedFilePath : "<<decryptedFilePath;
    QFile outputFile(decryptedFilePath);
    if (!outputFile.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        // Handle file saving error
        qDebug()<<"andle file saving error";
        return QVariant();
    }

    QTextStream stream(&outputFile);
    stream << decodedString;
    outputFile.close();
    // qDebug()<<"Decrypt "<<decryptedFilePath;
    emit decryptionProjectFinished(decryptedFilePath);
    return QVariant::fromValue(decryptedFilePath);
}

QFuture<bool> AES::encryptVideo(const QString &inputFilePath, const QString &outputFilePath, const QByteArray &encryptionKey)
{

    return QtConcurrent::run([this,inputFilePath, outputFilePath, encryptionKey]() {
        QFile inputFile(inputFilePath);
        QFile outputFile(outputFilePath);

        if (!inputFile.open(QIODevice::ReadOnly)) {
            // Failed to open input file
            return false;
        }
        if (!outputFile.open(QIODevice::WriteOnly)) {
            // Failed to open output file
            inputFile.close();
            return false;
        }


        qint64 totalBytes = inputFile.size();
        qint64 bytesProcessed = 0;

        const int bufferSize = 1024 * 1024; // 1MB
        char buffer[bufferSize];

        int keyLength = encryptionKey.length();
        int keyIndex = 0;
        while (!inputFile.atEnd()) {
            qint64 bytesRead = inputFile.read(buffer, bufferSize);

            for (qint64 i = 0; i < bytesRead; ++i) {
                buffer[i] = buffer[i] ^ encryptionKey[keyIndex];

                keyIndex++;
                if (keyIndex == keyLength) {
                    keyIndex = 0;
                }
            }

            outputFile.write(buffer, bytesRead);

            bytesProcessed += bytesRead;
            int progress = static_cast<int>((bytesProcessed * 100) / totalBytes);
            qDebug() << "Encryption progress:" << progress << "%";
            emit encryptionVideoProgressChanged(progress);
        }
        outputFile.close();
        inputFile.close();

        return true;
    });
}

QFuture<bool> AES::decryptVideo(const QString &inputFilePath, const QString &outputFilePath, const QByteArray &encryptionKey)
{
    return QtConcurrent::run([this,inputFilePath, outputFilePath, encryptionKey]() {
        // TODO: check file is exist before
        if (!dir.isValid()) {
            return false;
        }
        qDebug()<<"inputFilePath"<<inputFilePath;

        QString _fullname = getoutputFullFilename();
        QString fullname = _fullname + "/" + outputFilePath;
        QFile inputFile(inputFilePath);
        QFile outputFile(fullname);
        qDebug()<<"PATH : " <<fullname;
        if (!inputFile.open(QIODevice::ReadOnly)) {
            // Failed to open input file
            qDebug()<<"Failed to open input file";
            return false;
        }

        if (!outputFile.open(QIODevice::WriteOnly)) {
            // Failed to open output file
            qDebug()<<"Failed to open output file";
            inputFile.close();
            return false;
        }

        qint64 totalBytes = inputFile.size();
        qint64 bytesProcessed = 0;

        const int bufferSize = 1024 * 1024; // 1MB
        char buffer[bufferSize];

        int keyLength = encryptionKey.length();
        int keyIndex = 0;

        while (!inputFile.atEnd()) {
            qint64 bytesRead = inputFile.read(buffer, bufferSize);

            for (qint64 i = 0; i < bytesRead; ++i) {
                buffer[i] = buffer[i] ^ encryptionKey[keyIndex];

                keyIndex++;
                if (keyIndex == keyLength) {
                    keyIndex = 0;
                }
            }

            outputFile.write(buffer, bytesRead);

            bytesProcessed += bytesRead;
            int progress = static_cast<int>((bytesProcessed * 100) / totalBytes);
            qDebug() << "Decryption progress:" << progress << "%";
            emit encryptionVideoProgressChanged(progress);
        }

        outputFile.close();
        inputFile.close();

        emit decryptionVideoFinished(fullname);
        return true;
    });
}
QString AES::getoutputFullFilename() const {
    return outputFullFilename;
}
void AES::setoutputFullFilename(const QString& newFilename)
{
    outputFullFilename = newFilename;
}
QString AES::getinputPath() const {
    return m_inputPath;
}
void AES::setinputPath(const QString& inputPath)
{
    m_inputPath = inputPath;
}
AES::~AES()
{
    // Destructor implementation
    //   dir.removeRecursively();
}
