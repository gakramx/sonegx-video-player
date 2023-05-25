#ifndef AES_H
#define AES_H

#include <QObject>
#include <QVariant>

class AES : public QObject
{
    Q_OBJECT
public:
    explicit AES(QObject *parent = nullptr);
    Q_INVOKABLE QVariant encrypt(QByteArray plainText, QByteArray key);
    Q_INVOKABLE QVariant decrypt(QByteArray encodedText, QByteArray key);
    Q_INVOKABLE bool encryptVideo(const QString& inputFilePath, const QString& outputFilePath,const QByteArray& encryptionKey);
    Q_INVOKABLE bool decryptVideo(const QString& inputFilePath, const QString& outputFilePath,const QByteArray& encryptionKey);
signals:
    void encryptionVideoProgressChanged(int progress);
};

#endif // AES_H
