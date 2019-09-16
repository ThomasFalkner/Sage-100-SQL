SELECT 
Typ = 'Rechnungsempfaenger', 
ADR.Matchcode, 
ADR.Adresse, 
AUF.Adresse 'AdressNr' 

FROM KHKKontokorrent KTO 
INNER JOIN KHKAdressen AUF 
ON AUF.Mandant = KTO.Mandant AND AUF.Adresse = KTO.Adresse 
 
INNER JOIN KHKKontokorrent REE 
ON KTO.Mandant = REE.Mandant AND KTO.Rechnungsempfaenger = REE.Kto 

INNER JOIN KHKAdressen ADR 
ON REE.Mandant = ADR.Mandant AND REE.Adresse = ADR.Adresse 

UNION 
/* Ermittlung der abw. Lieferanschriften zu einem Auftraggeber */
SELECT 
Typ = 'Lieferanschrift', 
ADR.Matchcode, 
ADR.Adresse, 
AUF.Adresse 'AdressNr' 

FROM KHKKontokorrent KTO 
INNER JOIN KHKAdressen AUF 
ON AUF.Mandant = KTO.Mandant AND AUF.Adresse = KTO.Adresse 
 
INNER JOIN KHKAdressenverweise AVW  
ON KTO.Mandant = AVW.Mandant AND KTO.Kto = LEFT(AVW.Verweis,LEN(KTO.Kto))

INNER JOIN KHKAdressen ADR 
ON ADR.Mandant = AVW.Mandant AND ADR.Adresse = AVW.Adresse

WHERE AVW.Kategorie IN(11,41) 

UNION 
/* Ermittlung des abw. Auftraggebers zu einem Rechnungsempfänger */
SELECT 
Typ = 'Auftraggeber Rechnung', 
AUF.Matchcode, 
AUF.Adresse, 
ADR.Adresse 'AdressNr' 

FROM KHKKontokorrent KTO 
INNER JOIN KHKAdressen AUF 
ON AUF.Mandant = KTO.Mandant AND AUF.Adresse = KTO.Adresse 
 
INNER JOIN KHKKontokorrent REE 
ON KTO.Mandant = REE.Mandant AND KTO.Rechnungsempfaenger = REE.Kto 

INNER JOIN KHKAdressen ADR 
ON REE.Mandant = ADR.Mandant AND REE.Adresse = ADR.Adresse 

UNION 
/* Ermittlung des Auftraggeber zu abw. Lieferanschriften */
SELECT 
Typ = 'Auftraggeber Lieferung', 
AUF.Matchcode, 
AUF.Adresse, 
ADR.Adresse 'AdressNr' 

FROM KHKKontokorrent KTO 
INNER JOIN KHKAdressen AUF 
ON AUF.Mandant = KTO.Mandant AND AUF.Adresse = KTO.Adresse 
 
INNER JOIN KHKAdressenverweise AVW  
ON KTO.Mandant = AVW.Mandant AND KTO.Kto = LEFT(AVW.Verweis,LEN(KTO.Kto))

INNER JOIN KHKAdressen ADR 
ON ADR.Mandant = AVW.Mandant AND ADR.Adresse = AVW.Adresse

WHERE AVW.Kategorie IN(11,41)