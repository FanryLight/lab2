ServerGraphicsEditor
====================

A Symfony project created on August 27, 2016, 9:52 am.


http://localhost:8000/user/login

Тип запроса: POST.
Передается JSON файл с полями:
username - логин.
password - пароль.
Возвращается JsonResponse с apikey пользователя или ошибкой.

http://localhost:8000/user/registration

Тип запроса: POST.
Передается JSON файл с полями:
username - логин.
password - пароль.
Возвращается JsonResponse с apikey пользователя или ошибкой.


http://localhost:8000/document

Тип запроса: POST.
Передается форма с полями:
document - документ типа drg.
image - jpg/png.
apikey - apikey пользователя.
name - имя документа.
Возвращается Response с ошибкой.

http://localhost:8000/document

Тип запроса: GET.
В headers передается apikey пользователя.
Возвращается JsonResponse с массивом всех документов пользователя или ошибкой.

http://localhost:8000/document

Тип запроса: DELETE.
Передается JSON с полем id документа, который нужно удалить.
Возвращается Response с ошибкой.
