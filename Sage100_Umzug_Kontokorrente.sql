BEGIN TRANSACTION;

BEGIN TRY

	DECLARE @ZielKto AS VARCHAR(25)
	DECLARE @QuellKto AS VARCHAR(25)

	DECLARE @ZielAdresse AS INT
	DECLARE @QuellAdresse AS INT

	


	SET @Zieladresse = 
	SET @QuellAdresse = 

	SET @ZielKto = (SELECT TOP 1 Kto FROM KHKKontokorrent WHERE KtoArt = 'K' AND Adresse = @ZielAdresse)
	SET @QuellKto = (SELECT TOP 1 Kto FROM KHKKontokorrent WHERE KtoArt = 'K' AND Adresse = @QuellAdresse)



	UPDATE KHKBuchungserfassung SET KtoSoll = @ZielKto WHERE KtoSoll = @QuellKto
	UPDATE KHKBuchungserfassung SET KtoHaben = @ZielKto WHERE KtoHaben = @QuellKto
	UPDATE KHKBuchungserfassung SET Adresse =  @ZielAdresse  WHERE Adresse = @QuellAdresse 

	ALTER TABLE KHKOPHauptsatz NOCHECK CONSTRAINT ALL
	ALTER TABLE KHKOPNebensatz NOCHECK CONSTRAINT ALL

	UPDATE KHKOpNebensatz SET KtoKo = @ZielKto WHERE KtoKo = @QuellKto
	UPDATE KHKOpHauptsatz SET ktoko = @ZielKto WHERE KtoKo = @QuellKto
	UPDATE KHKOpHauptsatz SET Adresse = @ZielAdresse WHERE Adresse =  @QuellAdresse

	ALTER TABLE KHKOpHauptsatz WITH CHECK CHECK CONSTRAINT ALL
	ALTER TABLE KHKOPNebensatz WITH CHECK CHECK CONSTRAINT ALL


	UPDATE BSFundVerfahrenZahlungen SET kto= @ZielKto WHERE kto = @QuellKto
	UPDATE KHKBuchungsjournal SET GegenKto = @ZielKto WHERE GegenKto = @QuellKto
	UPDATE KHKBuchungsjournal SET Kto = @ZielKto WHERE Kto = @QuellKto
	
	DECLARE @cur as CURSOR;
	DECLARE @Periode AS VARCHAR(20)

	SET @cur = CURSOR FOR
	SELECT Periode 
	FROM KHKKontenumsatz WHERE Kto = @QuellKto
 
	OPEN @cur;
	FETCH NEXT FROM @cur INTO @Periode;
 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Wenn Zielkto in gleicher Periode bebucht wurde, dann update und Datnensatz von Quellkto l�schen
		IF (SELECT COUNT(*) FROM KHKKontenumsatz WHERE Kto = @ZielKto AND Periode = @Periode) = 1
			BEGIN
				MERGE INTO KHKKontenumsatz kumZiel
				USING KHKKontenumsatz kumQuelle
				ON kumZiel.Periode = kumQuelle.Periode
				AND kumQuelle.Kto = @QuellKto
				AND kumZiel.Kto = @ZielKto
				WHEN MATCHED THEN
				UPDATE 
				  SET kumZiel.SollEw = kumZiel.SollEw + kumQuelle.SolLEW,
					  kumZiel.HabenEw = kumZiel.HabenEW + kumQuelle.HabenEW;
				DELETE FROM KHKKontenumsatz WHERE Periode = @Periode AND Kto = @QuellKto
			END
		ELSE
			BEGIN
				UPDATE KHKKontenumsatz SET KTO = @ZielKto WHERE Kto = @QuellKto AND Periode = @Periode
			END
		FETCH NEXT FROM @cur INTO @Periode;
	END
 
	CLOSE @cur;
	DEALLOCATE @cur;

	PRINT @ZielKto;
	PRINT @QuellKto;

END TRY
BEGIN CATCH
    SELECT 
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;
GO
