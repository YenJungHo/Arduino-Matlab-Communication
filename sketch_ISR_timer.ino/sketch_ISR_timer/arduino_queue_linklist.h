#include <Arduino.h>
//#include <iostream>

template<class T>
struct QueueNode{
    T data;
    QueueNode<T> *next;
    QueueNode():data(0),next(0){};
    QueueNode(T x):data(x),next(0){};
};

template<class T>
class QueueList{
private:
    QueueNode<T> *front;
    QueueNode<T> *back;
    int size;
public:
    QueueList():front(0),back(0),size(0){};
    void Push(T x);
    void Pop();
    bool IsEmpty();
    T getFront();
    T getBack();
    int getSize();
};

template<class T>
void QueueList<T>::Push(T x){

    if (IsEmpty()) {
        front = new QueueNode<T>(x);
        back = front;
        size++;
        return;
    }

    QueueNode<T> *newNode = new QueueNode<T>(x);
    back->next = newNode;
    back = newNode;         // update back pointer
    size++;
}

template<class T>
void QueueList<T>::Pop(){

    if (IsEmpty()) {
        return;
    }

    QueueNode<T> *deletenode = front;
    front = front->next;    // update front pointer
    delete deletenode;
    deletenode = 0;
    size--;
}

template<class T>
T QueueList<T>::getFront(){

    if (IsEmpty()) {
        return -1;
    }

    return front->data;
}

template<class T>
T QueueList<T>::getBack(){

    if (IsEmpty()) {
        return -1;
    }

    return back->data;
}

template<class T>
bool QueueList<T>::IsEmpty(){
    return ((front && back) == 0);
}

template<class T>
int QueueList<T>::getSize(){
    return size;
}