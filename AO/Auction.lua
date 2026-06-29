
-- Попытаться сделать ставку на аукционе.
-- Результат - EVENT_AUCTION_BID_RESULT.
-- -- параметры
-- id: ObjectId - id аукциона
-- price: number - ставка
-- -- возвращаемые значения
-- нет
-- -- пример
-- local state = auction.GetAuctionState( id )
-- if state then
--   if not state.bidInProgress then
--     auction.Bid( id, 1000 )
--   end
-- end
function Facade.AO.auction.Bid( id, price )
    Facade.support.debug.strictTypes( "Facade.AO.auction.Bid", 
        { id, "number" },
        { price, "number" }
    )
    
    auction.Bid( id, price )
end

-- Попытаться выкупить предмет на аукционе по назначенной владельцем окончательной цене.
-- Результат - EVENT_AUCTION_BID_RESULT.
-- -- параметры
-- id: ObjectId - id аукциона
-- -- возвращаемые значения
-- нет
-- -- пример
-- local state = auction.GetAuctionState( id )
-- if state then
--   if not state.bidInProgress then
--     auction.Buyout( id )
--   end
-- end
function Facade.AO.auction.Buyout( id )
    Facade.support.debug.strictTypes( "Facade.AO.auction.Buyout", 
        { id, "number" }
    )
    
    auction.Buyout( id )
end

-- Возвращает true, если для предмета c таким id можно создать аукцион.
-- -- параметры
-- itemId: ObjectId - id предмета, который выставляется на аукцион; предмет должен находится в одном из контейнеров (например в инвентаре)
-- -- возвращаемые значения
-- boolean - true, если можно создать аукцион
-- -- пример
-- if auction.CanCreateForItem( itemId ) then
--   auction.CreateForItem( itemId, 10, 100, AUCTION_CREATETIME_HOURS24 )
-- end
function Facade.AO.auction.CanCreateForItem( id )
    Facade.support.debug.strictTypes( "Facade.AO.auction.CanCreateForItem", 
        { id, "number" }
    )
    
    return auction.CanCreateForItem( id )
end

-- Попытается создать аукцион с заданными параметрами. Время действия задано енумом - AUCTION_CREATETIME__....
-- Новый аукцион не создается, пока не закончено создание предыдущего. См. auction.IsCreationInProgress();
-- Результат создания - EVENT_AUCTION_CREATION_RESULT.
-- -- параметры
-- itemId: ObjectId - id предмета, который выставляется на аукцион
-- startPrice: number - стартовая цена (в меди, должна быть в диапазоне 1 - 999999999999)
-- buyoutPrice: number - окончательная цена выкупа с прекращением аукциона (в меди, должна быть в диапазоне 1 - 999999999999 либо -1, тогда нет досрочного выкупа)
-- timeLength: number (enum AUCTION_CREATETIME__...) - время действия аукциона
-- -- возвращаемые значения
-- нет
-- -- пример
-- if not auction.IsCreationInProgress() then
--   if auction.CanCreateForItem( itemId ) then
--     auction.CreateForItem( itemId, 10, 100, AUCTION_CREATETIME_HOURS24 )
--   end
-- end
function Facade.AO.auction.CreateForItem( itemId, startPrice, buyoutPrice, timeLength )
    Facade.support.debug.strictTypes( "Facade.AO.auction.CreateForItem", 
        { itemId, "number" },
        { startPrice, "number" },
        { buyoutPrice, "number" },
        { timeLength, "number" }
    )
    
    auction.CreateForItem( itemId, startPrice, buyoutPrice, timeLength )
end

-- Попытаться отменить аукцион.
-- Результат - EVENT_AUCTION_DISCARD_RESULT.
-- -- параметры
-- id: ObjectId - id аукциона
-- -- возвращаемые значения
-- нет
-- -- пример
-- local state = auction.GetAuctionState( id )
-- if state then
--   if not state.discarded and not state.discardInProgress then
--     auction.Discard( id )
--   end
-- end
function Facade.AO.auction.Discard( id )
    Facade.support.debug.strictTypes( "Facade.AO.auction.Discard", 
        { id, "number" }
    )
    
    auction.Discard( id )
end

-- Возвращает информацию об аукционе.
-- Статус участника - "ENUM_AuctionDescriptorParticipationStatus_..."
-- -- параметры
-- id: ObjectId - идентификатор аукциона
-- -- возвращаемые значения
-- table or nil - если аукцион найден, то таблица с полями:
--   id: ObjectId - id аукциона
--   itemId: ObjectId - id предмета, выставленного на аукцион
--   bidderName: WString - имя игрока, поставившего на аукционе последним
--   currentBid: number - последняя ставка
--   sellerName: WString - имя владельца аукциона
--   startPrice: number - стартовая цена
--   buyoutPrice: number - цена окончательного выкупа
--   participationStatus: string ("ENUM_AuctionDescriptorParticipationStatus_...") - отношение главного игрока к аукциону
--   timeLeftSeconds: сколько времени осталось в секундах
--   timeLeft: table - сколько времени осталось
--     d, h, m, s: number(int) - дней, часов, минут, секунд
-- -- пример
-- local auctions = auction.GetAuctions()
-- for i = 0, GetTableSize( auctions ) - 1 do
--   local auction = auction.GetAuctionInfo( auctions[ i ] )
--   if auction then
--     local itemInfo = avatar.GetItemInfo( auction.itemId )
--   end
-- end
-- avatar.GetItemInfo - больше не существует.
-- Для вывода информации стоит использовать корректное API:
-- itemLib.GetItemInfo( itemId ) - Общая информация о предмете.
-- itemLib.GetPriceInfo( itemId ) - Цены предмета при покупке/продаже в торговца.
-- Сообщено в тикете AS-POU-205-71315
function Facade.AO.auction.GetAuctionInfo( id )
    Facade.support.debug.strictTypes( "Facade.AO.auction.GetAuctionInfo", 
        { id, "number" }
    )
    
    local result = auction.GetAuctionInfo( id )
    
    return result and {
        id = result.id,
        itemId = result.itemId,
        bidderName = result.bidderName,
        currentBid = result.currentBid,
        sellerName = result.sellerName,
        startPrice = result.startPrice,
        buyoutPrice = result.buyoutPrice,
        participationStatus = result.participationStatus,
        timeLeftSeconds = result.timeLeftSeconds,
        timeLeft = result.timeLeft,
    } or nil
end

-- Возвращает список аукционов на указанной странице, найденных запросом auction.Search(...). Если запрос не был произведён, вернёт пустую таблицу.
-- -- параметры
-- нет
-- -- возвращаемые значения
-- table of ObjectId - индексированная с 0 таблица идентификаторов аукционов
-- -- пример
-- local auctions = auction.GetAuctions()
-- for i = 0, GetTableSize( auctions ) - 1 do
--   local auction = auction.GetAuctionInfo( auctions[ i ] )
-- end
function Facade.AO.auction.GetAuctions()
    -- fix > Game::LuaAuctionGetAuctions: player cannot use auction. Need auction interlocutor
    -- https://alloder.pro/forums/topic/7299-player-cannot-use-auction-need-auction-interlocutor/
    local interactorInfo = Facade.AO.avatar.GetInteractorInfo()
    
    if interactorInfo and interactorInfo.isAuction then
        return auction.GetAuctions()
    else
        return {}
    end
end

-- Возвращает количество аукционов, найденных запросом auction.Search(...). Если запрос не был произведён, вернёт 0.
-- -- параметры
-- нет
-- -- возвращаемые значения
-- number (int) - количество аукционов
-- -- пример
-- local auctionsCount = auction.GetAuctionsCount()
-- LogInfo( "Всего ", auctionsCount )
function Facade.AO.auction.GetAuctionsCount()
    return auction.GetAuctionsCount()
end

-- Возвращает номер текущей страницы списка аукционов, найденных запросом auction.Search(...). Если запрос не был произведён, вернёт 0. В случае успеха, страницы нумеруются с 1.
-- -- параметры
-- нет
-- -- возвращаемые значения
-- number (int) - номер страницы
-- -- пример
-- local auctionsPage = auction.GetAuctionsPage()
function Facade.AO.auction.GetAuctionsPage()
    return auction.GetAuctionsPage()
end

-- Возвращает количество страниц в списке всех аукционов, найденных запросом auction.Search(...). Если запрос не был произведён, вернёт 0.
-- -- параметры
-- нет
-- -- возвращаемые значения
-- number (int) - количество страницы
-- -- пример
-- local auctionsPage = auction.GetAuctionsPage()
-- local auctionsPageCount = auction.GetAuctionsPageCount()
-- LogInfo( "Страница", auctionsPage, " из ", auctionsPageCount )
function Facade.AO.auction.GetAuctionsPageCount()
    return auction.GetAuctionsPageCount()
end

-- Возвращает информацию о состоянии аукциона.
-- -- параметры
-- id: ObjectId - идентификатор аукциона
-- -- возвращаемые значения
-- table or nil - если аукцион найден, то таблица с полями:
--   bidInProgress: boolean - true, если ставка в процессе передачи
--   discardInProgress: boolean - true, если отмена аукциона в процессе
--   discarded: boolean - true, если аукцион уже отменён
-- -- пример
-- local state = auction.GetAuctionState( id )
-- if state then
--   if not state.discarded and not state.discardInProgress then
--     auction.Discard( id )
--   end
-- end
function Facade.AO.auction.GetAuctionState( id )
    Facade.support.debug.strictTypes( "Facade.AO.auction.GetAuctionState", 
        { id, "number" }
    )
    
    local result = auction.GetAuctionState( id )
    
    return result and {
        bidInProgress = result.bidInProgress,
        discardInProgress = result.discardInProgress,
        discarded = result.discarded,
    } or nil
end

-- Возвращает "приоритетный" уровень предмета при продаже на аукционе.
-- '''Приоритетный уровень предмета''' - это уровень, на который удобнее всего ориентироваться игроку при покупке предмета. В зависимости от некоторых условий приоритетным уровнем предмета будет являться либо '''уровень предмета''', либо '''требуемый уровень предмета'''.
-- -- параметры
-- id: ObjectId - идентификатор предмета
-- -- возвращаемые значения
-- Number(int) or nil - значение приоритетного уровня предмета, nil в случаи ошибки
-- -- пример
-- local foregroundLevel = auction.GetItemForegroundLevel( id )
function Facade.AO.auction.GetItemForegroundLevel( id )
    Facade.support.debug.strictTypes( "Facade.AO.auction.GetItemForegroundLevel", 
        { id, "number" }
    )
    
    local result = auction.GetItemForegroundLevel( id )
    
    return result or nil
end

-- Возвращает информацию об аукционах.
-- Если она еще не получена с сервера, то вернет nil и запросит сервер. В ответ прийдет: EVENT_AUCTION_PROPERTIES.
-- Если будет получена ошибка, то можно снова запросить сервер, но через некоорое время (сейчас 10 секунд).
-- Если придет успешное сообщение, то можно снова вызвать auction.GetProperties(). В этом случае запросы на сервер больше отсылаться не будут.
-- -- параметры
-- нет
-- -- возвращаемые значения
-- table or nil - если аукцион найден, то таблица с полями:
--   pawnFactorPercent: number(int) - залог в процентах
--   bidStepInPercent: number(int) - шаг ставки в процентах
--   discardingFineInPercent: number(int) - стоимость отмены аукциона в процентах
--   taxInPercent: number(int) - такса за аукцион в процентах
--   searchPageSize: number(int) - размер страницы поиска
--   bidIncreaseTimeSec: number(int) - интервал наращивания ставки в секундах
-- -- пример
-- local properties = auction.GetProperties()
-- if properties then
--   local pawn = properties.pawn * price / 100
-- end
function Facade.AO.auction.GetProperties()
    local result = auction.GetProperties()
    
    return result and {
        pawnFactorPercent = result.pawnFactorPercent,
        bidStepInPercent = result.bidStepInPercent,
        discardingFineInPercent = result.discardingFineInPercent,
        taxInPercent = result.taxInPercent,
        searchPageSize = result.searchPageSize,
        bidIncreaseTimeSec = result.bidIncreaseTimeSec,
    } or nil
end

-- Возвращает true, если было инициировано создание аукциона с помощью auction.CreateForItem(...), а ответ EVENT_AUCTION_CREATION_RESULT ещё не пришёл.
-- -- параметры
-- нет
-- -- возвращаемые значения
-- boolean - true, если идёт процесс создания аукциона
-- -- пример
-- if not auction.IsCreationInProgress() then
--   auction.Create( slot, startPrice, buyoutPrice, time )
-- end
function Facade.AO.auction.IsCreationInProgress()
    return auction.IsCreationInProgress()
end

-- Возвращает true, если был инициирован поиск аукционов с помощью auction.Search, а ответ EVENT_AUCTION_SEARCH_RESULT ещё не пришёл.
-- -- параметры
-- нет
-- -- возвращаемые значения
-- boolean - true, если идёт процесс создания аукциона
-- -- пример
-- if not auction.IsSearchInProgress() then
--   auction.Search( filter, field, ascending, page )
-- end
function Facade.AO.auction.IsSearchInProgress()
    return auction.IsSearchInProgress()
end

-- Проверяет, является ли допустимой маска для поиска по имени в фильтре поиска на аукционе. См. также auction.Search.
-- -- параметры
-- name: WString or nil - маска для поиска по имени (nil означает, что имя не используется, пустое)
-- -- возвращаемые значения
-- boolean - является ли маска допустимой
-- -- пример
-- local isValid = auction.IsSearchNameValid( filter.name )
-- wtSearchBtn:Enable( isValid )
function Facade.AO.auction.IsSearchNameValid( name )
    Facade.support.debug.strictTypes( "Facade.AO.auction.IsSearchNameValid", 
        { name, "?string" }
    )
    
    return auction.IsSearchNameValid( name )
end

-- Попытается найти все аукционы с заданными параметрами. Фильтр поиска задается в отдельной таблице. Нужно указать поле для сортировки, направление сортировки и желательную страницу результата.
-- Поле сортировки задается енумом AUCTION_ORDERFIELD_.... Некоторые поля фильтра требуют строковый псевдоним какого-либо ресурса (itemClass, raretyMin, raretyMax). Проверить валидность маски для поиска по имени можно функцией auction.IsSearchNameValid.
-- Дополнительные подробности: LuaApiDetails (закрытая ссылка)
-- Новый поиск не начнётся, пока не закончен старый. См. auction.IsSearchInProgress().
-- Результат поиска - EVENT_AUCTION_SEARCH_RESULT.
-- Список аукционов передается на клиент постранично и метод auction.GetAuctions() возвращает только список из указанной при поиске страницы auction.GetAuctionsPage(). Количество страниц - auction.GetAuctionsPageCount().
-- -- параметры
-- filter: Table - фильр поиска. Описан таблицей с полями, каждое из которых может быть пустым (см. ниже)
-- orderField: number (enum AUCTION_ORDERFIELD_...) - поле сортировке
-- asc: boolean - направление сортировки. true - сортировать по возрастанию
-- page: number (int) - номер страницы для показа, начиная с 1
-- -- поля фильтра:
-- name: WString or nil - маска для поиска по имени
-- itemClass: string or nil - псевдоним класса предмета
-- dressSlot: number (enum DRESS_SLOT_...) or nil - слот одежды
-- rarityMin: string or nil - псевдоним минимального качества предмета
-- rarityMax: string or nil - псевдоним максимального качества предмета
-- levelMin: int or nil - минимальный уровень предмета
-- levelMax: int or nil - максимальный уровень предмета
-- bidMin: number or nil - минимальная последняя ставка
-- bidMax: number or nil - максивальная последняя ставка
-- buyoutMin: number or nil - минимальная цена выкупа
-- buyoutMax: number or nil - максивальная цена выкупа
-- onlyMyAuctions: bool or nil - показывать только аукционы, созданные главным игроком
-- onlyAuctionsWithMyBids: bool or nil - показывать только аукционы с последней ставкой от главного игрока
-- rootCategory: ItemCategoryId or nil - идентификатор корневой категории
-- childCategory: ItemCategoryId or nil - идентификатор терминальной категории
-- -- возвращаемые значения
-- нет
-- -- пример
-- if not auction.IsSearchInProgress() then
--   local filter = {}
--   filter.levelMin = 10
--   filter.levelMax = 12
--   auction.Search( filter, AUCTION_ORDERFIELD_LEVEL, false, 1 )
-- end
function Facade.AO.auction.Search( filter, orderField, asc, page )
    Facade.support.debug.strictTypes( "Facade.AO.auction.Search", 
        { filter, function ( t )
            Facade.support.debug.strictTypes( "Facade.AO.auction.Search( filter )", {
                { t.name, "?string" },
                { t.itemClass, "?string" },
                { t.dressSlot, "?number" },
                { t.rarityMin, "?string" },
                { t.rarityMax, "?string" },
                { t.levelMin, "?number" },
                { t.levelMax, "?number" },
                { t.bidMin, "?number" },
                { t.bidMax, "?number" },
                { t.buyoutMin, "?number" },
                { t.buyoutMax, "?number" },
                { t.onlyMyAuctions, "?boolean" },
                { t.onlyAuctionsWithMyBids, "?boolean" },
                { t.rootCategory, "?number" },
                { t.childCategory, "?number" },
            } )
        end },
        { orderField, "number" },
        { asc, "boolean" },
        { page, "number" }
    )
    
    auction.Search( filter, orderField, asc, page )
end