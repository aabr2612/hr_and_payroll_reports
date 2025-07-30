USE [CLOUDERP]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EmpMonthCategorySheet]
    @SEmpCode VARCHAR(5),
    @EEmpCode VARCHAR(5),
    @SDate DATE = NULL,
    @EDate DATE = NULL,
    @FieldName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF @SDate IS NULL OR @EDate IS NULL
    BEGIN
        SET @EDate = ISNULL(@EDate, CAST(GETDATE() AS DATE));
        SET @SDate = ISNULL(@SDate, DATEADD(MONTH, -1, @EDate));
    END

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = '
    SELECT 
        GLB.BrName, 
        CONCAT(EO.EmpCode, '' '', EP.EmpName) AS Employee, 
        ES.' + QUOTENAME(@FieldName) + ' AS Value
    FROM EmpOfficeInfo AS EO
    JOIN EmpPersonalInfo AS EP ON EO.EmpCode = EP.EmpCode
    JOIN EmpSalary AS ES ON EO.EmpCode = ES.EmpCode
    JOIN GLBranch AS GLB ON EO.BrCode = GLB.BrCode
    WHERE
        (
            (EO.CCCode BETWEEN @SEmpCode AND @EEmpCode) OR
            (@SEmpCode IS NULL AND @EEmpCode >= EO.EmpCode) OR
            (@EEmpCode IS NULL AND @SEmpCode <= EO.EmpCode) OR
            (@SEmpCode IS NULL AND @EEmpCode IS NULL)
        )
        AND ES.SalSDate BETWEEN @SDate AND @EDate
	ORDER BY EO.EmpCode ASC;
    ';

    EXEC sp_executesql 
        @SQL,
        N'@SEmpCode VARCHAR(5), @EEmpCode VARCHAR(5), @SDate DATE, @EDate DATE',
        @SEmpCode, @EEmpCode, @SDate, @EDate;
END;
