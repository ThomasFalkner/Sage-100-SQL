SELECT 
UMS.Artikelnummer, 
UMS.Artikel, 
UMS.UmsatzEW, 
UMS.Umsatz, 
UMS.Menge,
UMS.zuletzt, 
lMenge = POS.Menge*BRT.StatistikWirkungUmsatz, 
ME = POS.MengeVKEinheit, 
lPreis = POS.Einzelpreis, 
lRabatt = POS.Rabatt, 
BEL.WKz, 
UMS.BelID, 
UMS.Adresse 

FROM 
(
SELECT 
SUM(POS.GesamtpreisInternEW*BRT.StatistikWirkungUmsatz) 'UmsatzEW', 
SUM(POS.GesamtpreisIntern*BRT.StatistikWirkungUmsatz) 'Umsatz', 
SUM(POS.Menge*BRT.StatistikWirkungUmsatz) 'Menge', 
ART.Artikelnummer, 
ART.Matchcode 'Artikel', 
MAX(BEL.Belegdatum) 'zuletzt', 
MAX(BEL.BelID) 'BelID', 
MAX(POS.BelPosID) 'BelPosID', 
KTO.Mandant, 
KTO.Adresse 

FROM 
KHKVKBelege BEL 

INNER JOIN KHKVKBelegePositionen POS 
ON POS.Mandant = BEL.Mandant AND POS.BelID = BEL.BelID

INNER JOIN KHKArtikel ART 
ON POS.Artikelnummer = ART.Artikelnummer AND POS.Mandant = ART.Mandant 

INNER JOIN KHKKontokorrent KTO
ON BEL.Mandant = KTO.Mandant AND BEL.A0Empfaenger = KTO.Kto

INNER JOIN KHKVKBelegarten BRT 
ON BEL.Belegkennzeichen = BRT.Kennzeichen 
AND BRT.MitFiBuUebergabe = (-1) AND BEL.SaveStatus = 2 

GROUP BY 
ART.Artikelnummer, 
ART.Matchcode, 
KTO.Mandant,  
KTO.Adresse) AS UMS 

INNER JOIN KHKVKBelegePositionen POS 
ON POS.Mandant = UMS.Mandant AND POS.BelPosID = UMS.BelPosID 

INNER JOIN KHKVKBelege BEL 
ON BEL.Mandant = POS.Mandant AND BEL.BelID = POS.BelID 

INNER JOIN KHKVKBelegarten BRT 
ON BRT.Kennzeichen = BEL.Belegkennzeichen 