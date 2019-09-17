SELECT 
/* Ermittlung der Zubehörartikel über Direktzuordnung */ 
ART.Artikelnummer 'Ursprungsnummer', 
ART.Matchcode 'Ursprungsartikel', 
ZAR.Artikelnummer, 
ZAR.Matchcode 'Zubehör', 
ZAR.Ersatzartikelnummer 'ersetzt', 
replace(replace(ZAR.Aktiv,0,'Nein'),-1,'Ja') AS 'Aktiv', 
'ZA' AS 'Typ' 

FROM 
KHKArtikel ART 

INNER JOIN KHKArtikelZubehoer AZU 
ON AZU.Mandant = ART.Mandant AND AZU.Ursprungsnummer = ART.Artikelnummer 

INNER JOIN KHKArtikel ZAR
ON ZAR.Mandant = AZU.Mandant AND ZAR.Artikelnummer = AZU.Zubehoernummer

WHERE AZU.UrsprungsArt = 1 AND AZU.ZubehoerArt = 1 

UNION 
SELECT 
/* Ermittlung der Zubehörartikel über Zubehörgruppen */ 
ART.Artikelnummer 'Ursprungsnummer', 
ART.Matchcode 'Ursprungsartikel', 
ZAR.Artikelnummer, 
ZAR.Matchcode 'Zubehör', 
ZAR.Ersatzartikelnummer 'ersetzt', 
replace(replace(ZAR.Aktiv,0,'Nein'),-1,'Ja') AS 'Aktiv', 
'ZG' AS 'Typ' 

FROM 
KHKArtikel ART 

INNER JOIN KHKArtikelZubehoer AZG 
ON AZG.Mandant = ART.Mandant AND AZG.Ursprungsnummer = ART.Artikelnummer

INNER JOIN KHKArtikelZubehoer AZU 
ON AZU.Mandant = AZG.Mandant AND AZU.Ursprungsnummer = AZG.Zubehoernummer 

INNER JOIN KHKArtikel ZAR
ON ZAR.Mandant = AZU.Mandant AND ZAR.Artikelnummer = AZU.Zubehoernummer 

WHERE 
AZG.UrsprungsArt = 1 
AND AZG.ZubehoerArt = 2 
AND AZU.UrsprungsArt = 2
AND AZU.ZubehoerArt = 1