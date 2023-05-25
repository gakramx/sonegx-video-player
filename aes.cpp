#include "aes.h"
#include <QtAES/qaesencryption.h>

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
