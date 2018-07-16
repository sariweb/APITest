# APITest
Реализовать экраны:

- Авторизация пользователя. (Контроллер LoginController - содержит кнопку [Login with VK] для перехода на страницу авторизации).
- Cписок постов: отображение постов из новостной ленты. (по желанию количество лайков и репостов).(Контроллер NewsController - появляется после авторизации пользователя, содержит список постов со следующими полями: имя пользователя,
 дата поста, аватар, текст поста, прикрепленная картинка).Отображать видео и аудио файлы не нужно.
- Дополнительно: детальный экран. Полный текст поста и показываем картинки. (контроллер DetailController - содержит детализированную информацию поста со всеми картинками).

Ограничения:

- Структурированный код, архитектура на свой выбор.
- Использовать Cocoa Pods для сторонних библиотек.
- UI должен быть написан Storyboard/Autolayout.
- Pull to refresh - автоподгрузка при скролле вниз (старые посты) и вверх (новые посты).
- Должна работать login/logout и смена юзера.
- Для локального хранения используем CoreData (по желанию, не обязательно).
- Кэширование картинок.
- Многопоточность с GСD. (Асинхронные запросы для загрузки картинок).
- Код поместить в свой репозиторий на GitHub.
