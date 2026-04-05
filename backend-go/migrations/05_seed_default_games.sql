-- +goose Up
INSERT INTO board_games (title, description, image_url) VALUES
('Монополия',            'Классическая игра про торговлю недвижимостью.',                        'https://cdn.pixabay.com/photo/2016/11/29/02/05/monopoly-1866978_640.jpg'),
('Колонизаторы (Catan)', 'Стратегия про строительство поселений и обмен ресурсами.',             'https://cdn.pixabay.com/photo/2020/06/08/15/01/catan-5274293_640.jpg'),
('Ticket to Ride',       'Стройте железнодорожные маршруты по всему миру.',                      'https://cdn.pixabay.com/photo/2022/09/12/12/50/board-game-7448610_640.jpg'),
('Каркассон',            'Строительство средневековых замков и дорог.',                          'https://cdn.pixabay.com/photo/2017/05/21/22/17/carcassonne-2332158_640.jpg'),
('Манчкин',              'Пародия на ролевые игры. Мочи монстров, хапай сокровища.',             'https://cdn.pixabay.com/photo/2019/07/13/07/58/munchkin-4334402_640.jpg'),
('Ужас Аркхэма',         'Кооперативная игра по мифам Лавкрафта.',                               'https://cdn.pixabay.com/photo/2017/08/06/22/01/arkham-horror-2595734_640.jpg'),
('Dixit',                'Игра в ассоциации с сюрреалистичными картинками.',                     'https://cdn.pixabay.com/photo/2018/03/22/17/07/dixit-3250547_640.jpg'),
('Пандемия',             'Спасите мир от четырех смертельных болезней.',                         'https://cdn.pixabay.com/photo/2018/09/16/14/29/pandemic-3681351_640.jpg'),
('Кодовые имена',        'Командная игра в слова для шпионов.',                                  'https://cdn.pixabay.com/photo/2017/12/16/19/54/codenames-3025182_640.jpg'),
('Мафия',                'Психологическая ролевая игра с детективным сюжетом.',                  'https://cdn.pixabay.com/photo/2016/11/18/14/04/mafia-1835471_640.jpg'),
('Uno',                  'Быстрая карточная игра для любой компании.',                           'https://cdn.pixabay.com/photo/2020/01/27/12/47/uno-4797275_640.jpg'),
('Эволюция',             'Создавайте своих существ и помогайте им выжить.',                      'https://cdn.pixabay.com/photo/2016/03/27/22/23/evolution-1284167_640.jpg'),
('Шахматы',              'Древняя логическая игра.',                                             'https://cdn.pixabay.com/photo/2016/11/22/23/44/chess-1851019_640.jpg'),
('Дженга',               'Стройте башню и не дайте ей упасть.',                                  'https://cdn.pixabay.com/photo/2019/09/18/15/52/jenga-4487006_640.jpg'),
('Scrabble',             'Составляйте слова и зарабатывайте очки.',                              'https://cdn.pixabay.com/photo/2016/11/29/04/21/scrabble-1867514_640.jpg'),
('Cluedo',               'Классический детектив. Найдите убийцу.',                               'https://cdn.pixabay.com/photo/2017/01/31/23/14/clue-2028320_640.jpg');

-- +goose Down
DELETE FROM board_games WHERE title IN (
    'Монополия','Колонизаторы (Catan)','Ticket to Ride','Каркассон',
    'Манчкин','Ужас Аркхэма','Dixit','Пандемия','Кодовые имена',
    'Мафия','Uno','Эволюция','Шахматы','Дженга','Scrabble','Cluedo'
);
