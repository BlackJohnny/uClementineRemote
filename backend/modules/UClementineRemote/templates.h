#ifndef TEMPLATES_H
#define TEMPLATES_H

#include <QVariantList>
#include <QList>

template <typename T>
QVariantList toVariantList( const QList<T*> &list )
{
    QVariantList newList;

    foreach(T* item, list)
        newList.append(QVariant::fromValue(*item));

/*    QList<T*>::iterator i;

    for (i = list.begin(); i != list.end(); ++i)
        newList.append(QVariant::fromValue(*i));
*/
    return newList;
}


#endif // TEMPLATES_H

