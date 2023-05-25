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

signals:

};

#endif // AES_H
