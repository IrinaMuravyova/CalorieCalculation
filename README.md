<p align="center">
      <img src="https://i.ibb.co/qmqv7ZY/2024-04-13-17-42-50.png" width="726">
</p>

<p align="center">
   <img src="https://img.shields.io/badge/Engine-XCode v15.3-blueviolet">
   <img src="https://img.shields.io/badge/Version-v1.0-blue">
   <img src="https://img.shields.io/badge/License-MIT-green">
</p>

## About

ПЭТ проект для отработки создания элементов интерфейса и практики прохождения этапов размещения приложения в App Strore.
Многопользовательский режим. Локализация на трех языках.Расчет данных кбжу для пользователя.


**В проекте используются:**

* UITableViewController
* UserInterface
* переход по segue
* кастомные TableViewCell
* локализация
* делегирование



### Техническое задание к проекту:

Приложение содержит две части - калькулятор кбжу и результат.
Несколько пользователей поочередно могут использовать приложение на одном устройстве.
Смена пользователя происходит по нажатию ан иконку текущего пользователя.
Редактирование списка пользователей - через боковое скрывающееся меню.
При активации бокового меню другие действия элементы интерфейса для пользователя закрыты.
Язык интерфейса определяется автоматически в зависимости от выбранного языка устройства.


![screenshot of sample](https://i.ibb.co/DfDxPxR/1734503008328-2.jpg)

## Documentation

### Models:

      Profile - основная модель данных
      TeamMember - для отображения команды разработчиков

#### Managers:

      StorageManager - для работы с UserDefaults

### ViewControllers:

      ViewController - основной экран приложения
      HelpViewController - содержит информацию о способе рассчета
      GreetingViewContoller - экран при добавлении нового пользователя
      MenuViewController - скрывающееся боковое меню
      TeamViewController - экран с командой разработчика

### Cells:
      ImageCollectionViewCell - для выбора иконки
      TeamViewCell - информация по участнику команды разработчика
  

## Developers

- [Irina Muravyova](https://github.com/IrinaMuravyova)

## License
Project CalorieCalculation is distributed under the MIT license.
