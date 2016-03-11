﻿
///////////////////////////////////////////////////////////////////////////////////
// УПРАВЛЕНИЕ ЗАПУСКОМ КОМАНД 1С:Предприятия 8
//

#Использовать logos
#Использовать asserts

Перем мКонтекстКоманды;
Перем мКаталогСборки;
Перем мВыводКоманды;
Перем мПутьКПлатформе1С;
Перем ЭтоWindows Экспорт;

Перем Лог;
Перем мИмяФайлаИнформации;

//////////////////////////////////////////////////////////////////////////////////
// Программный интерфейс

Процедура УстановитьКонтекст(Знач СтрокаСоединения, Знач Пользователь, Знач Пароль) Экспорт
	мКонтекстКоманды.КлючСоединенияСБазой = СтрокаСоединения;
	мКонтекстКоманды.ИмяПользователя = Пользователь;
	мКонтекстКоманды.Пароль = Пароль;

	ПоказатьКонтекстВРежимеОтладки();
КонецПроцедуры

Функция ПолучитьКонтекст() Экспорт
	КопияКонтекста = СкопироватьСтруктуру(мКонтекстКоманды);
	Возврат КопияКонтекста;
КонецФункции

Процедура ИспользоватьКонтекст(Знач Контекст) Экспорт
	мКонтекстКоманды = СкопироватьСтруктуру(Контекст);
	ПоказатьКонтекстВРежимеОтладки();
КонецПроцедуры

Процедура ПоказатьКонтекстВРежимеОтладки()
	Лог.Отладка("КлючСоединенияСБазой "+ мКонтекстКоманды.КлючСоединенияСБазой);
	Лог.Отладка("ИмяПользователя <"+ мКонтекстКоманды.ИмяПользователя+">");
	Лог.Отладка(?(ПустаяСтрока(мКонтекстКоманды.Пароль), "Пароль не задан", " Задан пароль "+ мКонтекстКоманды.Пароль));
КонецПроцедуры

Функция ПолучитьВерсиюИзХранилища(Знач СтрокаСоединения, Знач ПользовательХранилища, Знач ПарольХранилища, Знач НомерВерсии = Неопределено) Экспорт

	Параметры = СтандартныеПараметрыЗапускаКонфигуратора();

	Параметры.Добавить("/ConfigurationRepositoryF """+СтрокаСоединения+"""");
	Параметры.Добавить("/ConfigurationRepositoryN """+ПользовательХранилища+"""");

	Если Не ПустаяСтрока(ПарольХранилища) Тогда
		Параметры.Добавить("/ConfigurationRepositoryP """+ПарольХранилища+"""");
	КонецЕсли;

	ФайлРезультата = ОбъединитьПути(КаталогСборки(), "source.cf");

	Параметры.Добавить("/ConfigurationRepositoryDumpCfg """+ФайлРезультата + """");

	Если Не ПустаяСтрока(НомерВерсии) Тогда
		Параметры.Добавить("-v "+НомерВерсии);
	КонецЕсли;

	ВыполнитьКоманду(Параметры);

	Возврат ФайлРезультата;

КонецФункции

Процедура ОтключитьсяОтХранилища() Экспорт
	Параметры = СтандартныеПараметрыЗапускаКонфигуратора();
	Параметры.Добавить("/ConfigurationRepositoryUnbindCfg -force ");

	ВыполнитьКоманду(Параметры);
КонецПроцедуры

Процедура ЗагрузитьКонфигурациюИзФайла(Знач ФайлКонфигурации, Знач ОбновитьКонфигурациюИБ = Ложь) Экспорт

	// Выполняем загрузку и обновление за два шага, т.к.
	// иногда обновление конфигурации ИБ на новой базе проходит неудачно,
	// если запустить две операции в одной команде.

	Параметры = СтандартныеПараметрыЗапускаКонфигуратора();
	Параметры.Добавить("/LoadCfg """ + ФайлКонфигурации + """");
	ВыполнитьКоманду(Параметры);

	Если ОбновитьКонфигурациюИБ Тогда
		ОбновитьКонфигурациюБазыДанных(Ложь, Истина);
	КонецЕсли;

КонецПроцедуры

Процедура ОбновитьКонфигурациюБазыДанных(ПредупрежденияКакОшибки = Ложь, НаСервере = Истина, ДинамическоеОбновление = Ложь) Экспорт

	ПараметрыСвязиСБазой = СтандартныеПараметрыЗапускаКонфигуратора();
	ПараметрыСвязиСБазой.Добавить("/UpdateDBCfg");
	Если Не ДинамическоеОбновление Тогда
		ПараметрыСвязиСБазой.Добавить("-Dynamic–");
	КонецЕсли;
	
	Если ПредупрежденияКакОшибки Тогда
		ПараметрыСвязиСБазой.Добавить("-WarningsAsErrors");
	КонецЕсли;
	Если НаСервере Тогда
		ПараметрыСвязиСБазой.Добавить("-Server");
	КонецЕсли;

	ВыполнитьКоманду(ПараметрыСвязиСБазой);

КонецПроцедуры

Процедура ОбновитьКонфигурацию(Знач КаталогВерсии, Знач ИспользоватьПолныйДистрибутив = Ложь) Экспорт

	ПараметрыЗапуска = СтандартныеПараметрыЗапускаКонфигуратора();

	Если ИспользоватьПолныйДистрибутив = Неопределено Тогда
		ИспользоватьПолныйДистрибутив = Не КаталогСодержитФайлОбновления(КаталогВерсии);
	КонецЕсли;

	Если ИспользоватьПолныйДистрибутив Тогда
		ФайлОбновления = "1cv8.cf";
	Иначе
		ФайлОбновления = "1cv8.cfu";
	КонецЕсли;

	ПараметрыЗапуска.Добавить("/UpdateCfg " + ОбернутьВКавычки(ОбъединитьПути(КаталогВерсии, ФайлОбновления)));

	ВыполнитьКоманду(ПараметрыЗапуска);

КонецПроцедуры

Процедура СконвертироватьФайлКонфигурации(Знач ФайлКонфигурации) Экспорт

	Параметры = СтандартныеПараметрыЗапускаКонфигуратора();
	Параметры.Добавить("/ConvertFiles """ + ФайлКонфигурации + """");
	ВыполнитьКоманду(Параметры);

КонецПроцедуры

Процедура СоздатьФайловуюБазу(Знач КаталогБазы) Экспорт

	Лог.Отладка("Создаю файловую базу "+КаталогБазы);

	ОбеспечитьКаталог(КаталогБазы);
	УдалитьФайлы(КаталогБазы, "*.*");

	ПараметрыЗапуска = Новый Массив;
	ПараметрыЗапуска.Добавить("CREATEINFOBASE");
	ПараметрыЗапуска.Добавить("File="""+КаталогБазы+"""");
	ПараметрыЗапуска.Добавить("/Out""" + ФайлИнформации() + """");

	КодВозврата = ЗапуститьИПодождать(ПараметрыЗапуска);
	УстановитьВывод(ПрочитатьФайлИнформации());
	Если КодВозврата <> 0 Тогда
		ВызватьИсключение ВыводКоманды();
	КонецЕсли;

КонецПроцедуры

Процедура ЗагрузитьИнформационнуюБазу(ПутьВыгрузкиИБ) Экспорт
	ФайлВыгрузки = Новый Файл(ПутьВыгрузкиИБ);
	Ожидаем.Что(ФайлВыгрузки.Существует(), "Файл выгрузки <"+ПутьВыгрузкиИБ+"> существует, а это не так").ЭтоИстина();

	ПараметрыЗапуска = СтандартныеПараметрыЗапускаКонфигуратора();

	ПараметрыЗапуска.Добавить("/RestoreIB " + ОбернутьВКавычки(ПутьВыгрузкиИБ));

	ВыполнитьКоманду(ПараметрыЗапуска);
КонецПроцедуры

Процедура ВыполнитьКоманду(Знач Параметры) Экспорт

	ПроверитьВозможностьВыполненияКоманды();

	Файл = Новый Файл(ФайлИнформации());
	Если Файл.Существует() Тогда
		Попытка
			Лог.Отладка("Удаляю файл информации 1С");
			УдалитьФайлы(Файл.ПолноеИмя);
		Исключение
			Лог.Предупреждение("Не удалось удалить файл информации: " + ОписаниеОшибки());
		КонецПопытки;
	КонецЕсли;

	КодВозврата = ЗапуститьИПодождать(Параметры);
	УстановитьВывод(ПрочитатьФайлИнформации());
	Если КодВозврата <> 0 Тогда
		Лог.Информация("Получен ненулевой код возврата "+КодВозврата+". Выполнение скрипта остановлено!");
		ВызватьИсключение ВыводКоманды();
	Иначе
		Лог.Отладка("Код возврата равен 0");
	КонецЕсли;

КонецПроцедуры

Функция ПолучитьПараметрыЗапуска() Экспорт
	Возврат СтандартныеПараметрыЗапускаКонфигуратора();
КонецФункции

Процедура ВыполнитьРасширеннуюПроверкуКонфигуратора(Ключи) Экспорт
    
	Параметры = СтандартныеПараметрыЗапускаКонфигуратора();
	
	Параметры.Добавить("/CheckConfig");
	
	Для Каждого СтрокаКлюча Из Ключи Цикл
	    Если СтрокаКлюча.Значение = Истина Тогда
		    Параметры.Добавить(СтрокаКлюча.Ключ);
		КонецЕсли;
	КонецЦикла; 
	
	ВыполнитьКоманду(Параметры);
	
КонецПроцедуры

Процедура ВыполнитьСинтаксическийКонтроль(
			Знач ТонкийКлиент = Истина,
			Знач ВебКлиент = Истина,
			Знач Сервер = Истина,
			Знач ВнешнееСоединение = Истина,
			Знач ТолстыйКлиентОбычноеПриложение = Истина) Экспорт

	Параметры = СтандартныеПараметрыЗапускаКонфигуратора();

	Параметры.Добавить("/CheckConfig");

	ДобавитьФлагПроверки(Параметры, ТонкийКлиент, "-ThinClient");
	ДобавитьФлагПроверки(Параметры, ВебКлиент, "-WebClient");
	ДобавитьФлагПроверки(Параметры, Сервер, "-Server");
	ДобавитьФлагПроверки(Параметры, ВнешнееСоединение, "-ExternalConnection");
	ДобавитьФлагПроверки(Параметры, ТолстыйКлиентОбычноеПриложение, "-ThickClientOrdinaryApplication");

	ВыполнитьКоманду(Параметры);

КонецПроцедуры

Процедура ЗапуститьВРежимеПредприятия(Знач КлючЗапуска = "MIGRATE", Знач УправляемыйРежим = Неопределено, Знач ДополнительныеКлючи = Неопределено) Экспорт
	ПараметрыСвязиСБазой = ПолучитьПараметрыЗапуска();
	ПараметрыСвязиСБазой[0] = "ENTERPRISE";
	ПараметрыСвязиСБазой.Добавить("/C"+КлючЗапуска);
	Если УправляемыйРежим = Истина Тогда
		ПараметрыСвязиСБазой.Вставить(2, "/RunModeManagedApplication");
	ИначеЕсли УправляемыйРежим = Ложь Тогда
		ПараметрыСвязиСБазой.Вставить(2, "/RunModeOrdinaryApplication");
	КонецЕсли;

	Если ДополнительныеКлючи <> Неопределено Тогда
		ПараметрыСвязиСБазой.Добавить(ДополнительныеКлючи);
	КонецЕсли;

	ВыполнитьКоманду(ПараметрыСвязиСБазой);

КонецПроцедуры

Процедура ДобавитьФлагПроверки(Знач Параметры, Знач ФлагПроверки, Знач ИмяФлага)

	Если ФлагПроверки Тогда
		Параметры.Добавить(ИмяФлага);
	КонецЕсли;

КонецПроцедуры

Функция КаталогСодержитФайлОбновления(Знач КаталогВерсии)

	ФайлОбновления = Новый Файл(ОбъединитьПути(КаталогВерсии, "1cv8.cfu"));
	Возврат ФайлОбновления.Существует();

КонецФункции

Функция ПутьКВременнойБазе() Экспорт
	Возврат ОбъединитьПути(КаталогСборки(), "v8r_TempDB");
КонецФункции

//////////////////////////////////////////////////
// Вспомогательные и настроечные функции

Функция ПолучитьПутьКВерсииПлатформы(Знач ВерсияПлатформы) Экспорт

	Если Лев(ВерсияПлатформы, 2) <> "8." Тогда
		ВызватьИсключение "Неверная версия платформы <"+ВерсияПлатформы+">";
	КонецЕсли;

	Если ЭтоWindows = Истина Тогда
	
		СписокСтрок = РазложитьСтрокуВМассивПодстрок(ВерсияПлатформы, ".");
		Если СписокСтрок.Количество() < 2 Тогда
			ВызватьИсключение "Маска версии платформы должна содержать, как минимум, минорную и мажорную версию, т.е. Maj.Min[.Release][.Build]";
		КонецЕсли;
		
		КаталогиУстановкиПлатформы = СобратьВозможныеКаталогиУстановкиПлатформыWindows();
		
		Если КаталогиУстановкиПлатформы.Количество() = 0 Тогда
			Лог.Отладка("В конфигах стартера не найдены пути установки. Пробую стандартные пути наугад.");
			файлProgramFiles = Новый Файл("C:\Program Files (x86)\");
			Если Не файлProgramFiles.Существует() Тогда
				файлProgramFiles = Новый Файл("C:\Program Files\");
				Если Не файлProgramFiles.Существует() Тогда
					ВызватьИсключение "Не обнаружено установленных версий платформы 1С";
				КонецЕсли;
			КонецЕсли;
			
			КаталогиУстановкиПлатформы.Добавить(ОбъединитьПути(файлProgramFiles.ПолноеИмя, "1Cv8"));
			КаталогиУстановкиПлатформы.Добавить(ОбъединитьПути(файлProgramFiles.ПолноеИмя, "1Cv82"));
			
		КонецЕсли;
		
		НужныйПуть = Неопределено;
		Для Каждого ВозможныйПуть Из КаталогиУстановкиПлатформы Цикл
		
			Лог.Отладка("Выполняю попытку поиска версии в каталоге " + ВозможныйПуть);
			
			МассивФайлов = НайтиФайлы(ВозможныйПуть, ВерсияПлатформы+"*");
			Если МассивФайлов.Количество() = 0 Тогда
				Лог.Отладка("Не найдено ни одного каталога с версией.");
				Продолжить;
			КонецЕсли;

			ИменаВерсий = Новый Массив;
			Для Каждого ЭлементМассива Из МассивФайлов Цикл
				правыйСимвол = Прав(ЭлементМассива.Имя,1);
				Если правыйСимвол < "0" или правыйСимвол > "9" Тогда
					Продолжить;
				КонецЕсли;
				ИменаВерсий.Добавить(ЭлементМассива.Имя);
			КонецЦикла;

			МаксВерсия = ИменаВерсий[0];
			Для Сч = 1 По ИменаВерсий.Количество()-1 Цикл
				Если МаксВерсия < ИменаВерсий[Сч] Тогда
					МаксВерсия = ИменаВерсий[Сч];
				КонецЕсли;
			КонецЦикла;
			
			НужныйПуть = Новый Файл(ОбъединитьПути(ВозможныйПуть, МаксВерсия, "bin\1cv8.exe"));
			Лог.Отладка("Версия найдена: " + НужныйПуть.ПолноеИмя);
			Прервать;
			
		КонецЦикла;
		
		Если НужныйПуть = Неопределено Тогда
			ВызватьИсключение "Не найден путь к платформе 1С <"+ВерсияПлатформы+">";
		КонецЕсли;
		
	Иначе
		// help wanted: на Линукс конфиг стартера лежит в ~/.1C/1cestart.
		КаталогУстановки = Новый Файл("/opt/1C/v8.3/i386");
		Если НЕ КаталогУстановки.Существует() Тогда
			КаталогУстановки = Новый Файл("/opt/1C/v8.3/x86_64");
		КонецЕсли;
		НужныйПуть = Новый Файл(Строка(КаталогУстановки.ПолноеИмя) + "/" + "1cv8");
	КонецЕсли;
	
	Если Не НужныйПуть.Существует() Тогда
		ВызватьИсключение "Ошибка определения версии платформы. Файл <"+НужныйПуть.ПолноеИмя+"> не существует";
	КонецЕсли;

	Возврат НужныйПуть.ПолноеИмя;

КонецФункции

Процедура УстановитьКлючРазрешенияЗапуска(Знач Ключ) Экспорт
	мКонтекстКоманды.КлючРазрешенияЗапуска = Ключ;
КонецПроцедуры

Функция ВыводКоманды() Экспорт
	Возврат мВыводКоманды;
КонецФункции

Функция КаталогСборки(Знач Каталог = "") Экспорт

	Если мКаталогСборки = Неопределено Тогда
		мКаталогСборки = ТекущийКаталог();
	КонецЕсли;

	Если Каталог = "" Тогда
		Возврат мКаталогСборки;
	Иначе
		ТекКаталог = мКаталогСборки;
		мКаталогСборки = Каталог;
		Возврат ТекКаталог;
	КонецЕсли;

КонецФункции

Функция ПутьКПлатформе1С(Знач Путь = "") Экспорт

	Если Путь = "" Тогда
		Возврат мПутьКПлатформе1С;
	Иначе
		ТекЗначение = мПутьКПлатформе1С;
		мПутьКПлатформе1С = Путь;
		Возврат ТекЗначение;
	КонецЕсли;

КонецФункции

Процедура ИспользоватьВерсиюПлатформы(Знач МаскаВерсии) Экспорт
	Путь = ПолучитьПутьКВерсииПлатформы(МаскаВерсии);
	ПутьКПлатформе1С(Путь);
КонецПроцедуры

Функция ПутьКТонкомуКлиенту1С(Знач ПутьКПлатформе1С = "") Экспорт
	Сообщить("ПутьКТонкомуКлиенту1С: Путь платформы 1С <"+ПутьКПлатформе1С+">");
	Если ПутьКПлатформе1С = "" Тогда
		ПутьКПлатформе1С = ПутьКПлатформе1С();
		Сообщить("ПутьКТонкомуКлиенту1С: вычислили Путь платформы 1С <"+ПутьКПлатформе1С+">");
	КонецЕсли;

	ФайлПриложения = Новый Файл(ПутьКПлатформе1С);
	Каталог = ФайлПриложения.Путь;
	ФайлПриложения = Новый Файл(ОбъединитьПути(Каталог, "1cv8c.exe"));
	Если Не ФайлПриложения.Существует() Тогда
		ВызватьИсключение "Не установлен тонкий клиент";
	КонецЕсли;

	Сообщить("ПутьКТонкомуКлиенту1С: получили путь к тонкому клиенту 1С <"+ФайлПриложения.ПолноеИмя+">");
	Возврат ФайлПриложения.ПолноеИмя;

КонецФункции

Процедура УстановитьИмяФайлаСообщенийПлатформы(Знач Имя) Экспорт
	мИмяФайлаИнформации = Имя; // если будет абс. путь, то ОбъединитьПути отработает корректно.
КонецПроцедуры

Процедура УдалитьВременнуюБазу() Экспорт

	Если ВременнаяБазаСуществует() Тогда
		КаталогВременнойБазы = ПутьКВременнойБазе();
		Лог.Отладка("Удаляю временную базу: "+КаталогВременнойБазы);
		УдалитьФайлы(КаталогВременнойБазы);
	КонецЕсли;

КонецПроцедуры

Функция СобратьВозможныеКаталогиУстановкиПлатформыWindows()

	СИ = Новый СистемнаяИнформация;
		
	// Ищем в расположениях для Vista и выше.
	// Желающие поддержать пути в Windows XP - welcome
	КаталогВсеПользователи = СИ.ПолучитьПеременнуюСреды("ALLUSERSPROFILE");
	КаталогТекущегоПользователя = СИ.ПолучитьПеременнуюСреды("APPDATA");
	
	МассивПутей = Новый Массив;
	СуффиксРасположения = "1C\1CEStart\1CEStart.cfg";
	
	ОбщийКонфиг = ОбъединитьПути(КаталогВсеПользователи, СуффиксРасположения);
	ДополнитьМассивРасположенийИзКонфигурационногоФайла(ОбщийКонфиг, МассивПутей);
	
	ПользовательскийКонфиг = ОбъединитьПути(КаталогТекущегоПользователя, СуффиксРасположения);
	ДополнитьМассивРасположенийИзКонфигурационногоФайла(ПользовательскийКонфиг, МассивПутей);
	
	Возврат МассивПутей;
	
КонецФункции

Процедура ДополнитьМассивРасположенийИзКонфигурационногоФайла(Знач ИмяФайла, Знач МассивПутей)
	
	ФайлКонфига = Новый Файл(ИмяФайла);
	Если Не ФайлКонфига.Существует() Тогда
		Лог.Отладка("Конфигурационный файл " + ИмяФайла + " не найден.");
		Возврат;
	КонецЕсли;
	
	Лог.Отладка("Читаю конфигурационный файл " + ИмяФайла + ".");
	Конфиг = Новый КонфигурацияСтартера;
	Конфиг.Открыть(ИмяФайла);
	
	Значения = Конфиг.ПолучитьСписок("InstalledLocation");
	Если Значения <> Неопределено Тогда
		Для Каждого Путь Из Значения Цикл
			МассивПутей.Добавить(Путь);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////////
// Служебные процедуры

Функция СтандартныеПараметрыЗапускаКонфигуратора()

	Лог.Отладка("КлючСоединенияСБазой "+КлючСоединенияСБазой());
	Лог.Отладка("ИмяПользователя <"+мКонтекстКоманды.ИмяПользователя+">");

	ПараметрыЗапуска = Новый Массив;
	ПараметрыЗапуска.Добавить("DESIGNER");
	ПараметрыЗапуска.Добавить(КлючСоединенияСБазой());

	ПараметрыЗапуска.Добавить("/Out" + ОбернутьВКавычки(ФайлИнформации()));
	Если Не ПустаяСтрока(мКонтекстКоманды.ИмяПользователя) Тогда
		ПараметрыЗапуска.Добавить("/N" + ОбернутьВКавычки(мКонтекстКоманды.ИмяПользователя));
	КонецЕсли;
	Если Не ПустаяСтрока(мКонтекстКоманды.Пароль) Тогда
		ПараметрыЗапуска.Добавить("/P" + ОбернутьВКавычки(мКонтекстКоманды.Пароль));
	КонецЕсли;
	ПараметрыЗапуска.Добавить("/WA+");
	Если Не ПустаяСтрока(мКонтекстКоманды.КлючРазрешенияЗапуска) Тогда
		ПараметрыЗапуска.Добавить("/UC" + ОбернутьВКавычки(мКонтекстКоманды.КлючРазрешенияЗапуска));
	КонецЕсли;
	ПараметрыЗапуска.Добавить("/DisableStartupMessages");
	ПараметрыЗапуска.Добавить("/DisableStartupDialogs");

	Возврат ПараметрыЗапуска;

КонецФункции

Процедура ПроверитьВозможностьВыполненияКоманды()

	Если Не ЗначениеЗаполнено(ПутьКПлатформе1С()) Тогда
		ВызватьИсключение "Не задан путь к платформе 1С";
	КонецЕсли;

	Лог.Отладка("Проверяю равенство КлючСоединенияСБазой() = КлючВременногоКонтекста() и Не ВременнаяБазаСуществует()");
	Лог.Отладка("КлючСоединенияСБазой() "+КлючСоединенияСБазой());
	Лог.Отладка("КлючВременногоКонтекста() "+КлючВременногоКонтекста());
	Лог.Отладка("ВременнаяБазаСуществует() "+ВременнаяБазаСуществует());

	Если КлючСоединенияСБазой() = КлючВременногоКонтекста() и Не ВременнаяБазаСуществует() Тогда
		Лог.Отладка("Равенство выполняется.");
		СоздатьВременнуюБазу();
	Иначе
		Лог.Отладка("Равенство не выполняется.");
	КонецЕсли;

КонецПроцедуры

Функция КлючСоединенияСБазой()
	Если ПустаяСтрока(мКонтекстКоманды.КлючСоединенияСБазой) Тогда
		Возврат КлючВременногоКонтекста();
	Иначе
		Возврат мКонтекстКоманды.КлючСоединенияСБазой;
	КонецЕсли;
КонецФункции

Процедура СоздатьВременнуюБазу()

	КаталогВременнойБазы = ПутьКВременнойБазе();
	Лог.Отладка("Создаю временную базу. Путь "+КаталогВременнойБазы);

	СоздатьФайловуюБазу(КаталогВременнойБазы);

КонецПроцедуры

Функция ЗапуститьИПодождать(Знач Параметры)

	СтрокаЗапуска = "";
	СтрокаДляЛога = "";
	Для Каждого Параметр Из Параметры Цикл

		СтрокаЗапуска = СтрокаЗапуска + " " + Параметр;

		Если Лев(Параметр,2) <> "/P" и Лев(Параметр,25) <> "/ConfigurationRepositoryP" Тогда
			СтрокаДляЛога = СтрокаДляЛога + " " + Параметр;
		КонецЕсли;

	КонецЦикла;

	КодВозврата = 0;

	Приложение = ОбернутьВКавычки(ПутьКПлатформе1С());
	Лог.Информация(Приложение + СтрокаДляЛога);

	Если ЭтоWindows = Ложь Тогда 
		СтрокаЗапуска = "sh -c '"+Приложение + СтрокаЗапуска + "'";
	Иначе
		СтрокаЗапуска = Приложение + СтрокаЗапуска;
	КонецЕсли;
	ЗапуститьПриложение(СтрокаЗапуска, , Истина, КодВозврата);

	Возврат КодВозврата;

КонецФункции

Функция ПрочитатьФайлИнформации()

	Текст = "";

	Файл = Новый Файл(ФайлИнформации());
	Если Файл.Существует() Тогда
		Чтение = Новый ЧтениеТекста(Файл.ПолноеИмя);
		Текст = Чтение.Прочитать();
		Чтение.Закрыть();
	Иначе
		Текст = "Информации об ошибке нет";
	КонецЕсли;

	Лог.Отладка("файл информации:
	|"+Текст);
	Возврат Текст;

КонецФункции

Процедура УстановитьВывод(Знач Сообщение)
	мВыводКоманды = Сообщение;
КонецПроцедуры

Функция ФайлИнформации() Экспорт
	Если мИмяФайлаИнформации = Неопределено Тогда
		мИмяФайлаИнформации = "log.txt";
	КонецЕсли;

	Возврат ОбъединитьПути(КаталогСборки(), мИмяФайлаИнформации);
КонецФункции

Процедура ОбеспечитьКаталог(Знач Каталог)

	Файл = Новый Файл(Каталог);
	Если Не Файл.Существует() Тогда
		СоздатьКаталог(Каталог);
	ИначеЕсли Не Файл.ЭтоКаталог() Тогда
		ВызватьИсключение "Каталог " + Каталог + " не является каталогом";
	КонецЕсли;

КонецПроцедуры

Функция КлючВременногоКонтекста()
	Возврат "/F""" + ПутьКВременнойБазе() + """";
КонецФункции

Функция ВременнаяБазаСуществует() Экспорт
	ФайлБазы = Новый Файл(ОбъединитьПути(ПутьКВременнойБазе(), "1Cv8.1CD"));
	
	Возврат ФайлБазы.Существует();
КонецФункции

Функция РазложитьСтрокуВМассивПодстрок(ИсходнаяСтрока, Разделитель)

	МассивПодстрок = Новый Массив;
	ОстатокСтроки = ИсходнаяСтрока;

	Поз = -1;
	Пока Поз <> 0 Цикл

		Поз = Найти(ОстатокСтроки, Разделитель);
		Если Поз > 0 Тогда
			Подстрока = Лев(ОстатокСтроки, Поз-1);
			ОстатокСтроки = Сред(ОстатокСтроки, Поз+1);
		Иначе
			Подстрока = ОстатокСтроки;
		КонецЕсли;

		МассивПодстрок.Добавить(Подстрока);

	КонецЦикла;

	Возврат МассивПодстрок;

КонецФункции

Функция ОбернутьВКавычки(Знач Строка);
	Если Лев(Строка, 1) = """" и Прав(Строка, 1) = """" Тогда
		Возврат Строка;
	Иначе
		Возврат """" + Строка + """";
	КонецЕсли;
КонецФункции

Процедура Инициализация()
	СистемнаяИнформация = Новый СистемнаяИнформация;
	ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;

	мКонтекстКоманды = Новый Структура;
	мКонтекстКоманды.Вставить("КлючСоединенияСБазой", "");
	мКонтекстКоманды.Вставить("ИмяПользователя", "");
	мКонтекстКоманды.Вставить("Пароль", "");
	мКонтекстКоманды.Вставить("КлючРазрешенияЗапуска", "");

	ПутьКПлатформе1С(ПолучитьПутьКВерсииПлатформы("8.3"));
КонецПроцедуры

Функция СкопироватьСтруктуру(Знач Источник)

	Копия = Новый Структура;
	Для Каждого КлючИЗначение Из Источник Цикл
		Копия.Вставить(КлючИЗначение.Ключ, КлючИЗначение.Значение);
	КонецЦикла;

	Возврат Копия;

КонецФункции

Процедура ОбновитьКонфигурациюБазыДанныхИзХранилища(СтрокаСоединения, ПользовательХранилища, ПарольХранилища="") Экспорт

	ПараметрыСвязиСБазой = СтандартныеПараметрыЗапускаКонфигуратора();
	
	ПараметрыСвязиСБазой.Добавить("/ConfigurationRepositoryF """+СтрокаСоединения+"""");
	ПараметрыСвязиСБазой.Добавить("/ConfigurationRepositoryN """+ПользовательХранилища+"""");
	
	Если Не ПустаяСтрока(ПарольХранилища) Тогда
		ПараметрыСвязиСБазой.Добавить("/ConfigurationRepositoryP """+ПарольХранилища+"""");
	КонецЕсли;	
	
	ПараметрыСвязиСБазой.Добавить("/ConfigurationRepositoryUpdateCfg");
	ПараметрыСвязиСБазой.Добавить("-force");
	
	ПараметрыСвязиСБазой.Добавить("/UpdateDBCfg");
	
	ВыполнитьКоманду(ПараметрыСвязиСБазой);
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////////////
// Инициализация

Лог = Логирование.ПолучитьЛог("oscript.lib.v8runner");
Инициализация();
