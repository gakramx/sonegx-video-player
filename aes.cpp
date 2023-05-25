#include "aes.h"
#include <QtAES/qaesencryption.h>
#include <QFile>
#include <QCryptographicHash>
#include <QDebug>
AES::AES(QObject *parent)
    : QObject{parent}
{

}
QVariant AES::encrypt(QByteArray plainText, QByteArray key)
{
    QAESEncryption encryption(QAESEncryption::AES_128, QAESEncryption::ECB);
    QByteArray encodedText = encryption.encode(plainText, key);
     return QVariant::fromValue(encodedText);
}

QVariant AES::decrypt(QByteArray encodedText, QByteArray key)
{
    QAESEncryption encryption(QAESEncryption::AES_128, QAESEncryption::ECB);
    QByteArray decodedText = encryption.decode(encodedText, key);
    QString decodedString = QString(encryption.removePadding(decodedText));
   return QVariant::fromValue(decodedString);
}
bool AES::encryptVideo(const QString& inputFilePath, const QString& outputFilePath, const QByteArray& encryptionKey){
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
}
bool AES::decryptVideo(const QString &inputFilePath, const QString &outputFilePath, const QByteArray &encryptionKey){
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
       qDebug() << "Decryption progress:" << progress << "%";
       emit encryptionVideoProgressChanged(progress);
    }

    outputFile.close();
    inputFile.close();

    return true;
}
