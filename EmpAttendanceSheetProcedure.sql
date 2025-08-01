USE [CLOUDERP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EmpAttendanceSheet]
    @SCCCode VARCHAR(50),
    @ECCCode VARCHAR(50),
    @SDate DATE,
    @EDate DATE,
    @EmpCode VARCHAR(MAX),
    @SortBy VARCHAR(MAX),
    @Attend VARCHAR(MAX)

AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = '
    SELECT 
        CONCAT(EO.EmpCode, '' '', EP.EmpName) AS EmpCode,
        EA.AttendDate,
        EA.Attend,
        CONCAT(EO.CCCode, '' '', GLCC.CCDescription) AS CCCode,
        GLB.BrName,
        HRD.DesigName,
        EO.BrCode,
        EA.OfficeIn,
        EA.OfficeOut,
        CASE 
            WHEN EA.OfficeIn IS NOT NULL AND EA.OfficeOut IS NOT NULL THEN
                CAST(DATEDIFF(MINUTE, 
                              CAST(EA.OfficeIn AS TIME), 
                              CAST(EA.OfficeOut AS TIME)) AS FLOAT) / 60.0
            ELSE NULL
        END AS WorkTime
    FROM dbo.EmpOfficeInfo AS EO
    INNER JOIN dbo.EmpPersonalInfo AS EP ON EP.EmpCode = EO.EmpCode
    INNER JOIN dbo.EmpAttendance AS EA ON EA.EmpCode = EO.EmpCode
    INNER JOIN dbo.GLCostCenter AS GLCC ON GLCC.CCCode = EO.CCCode
    INNER JOIN dbo.GLBranch AS GLB ON GLB.BrCode = EO.BrCode
    INNER JOIN dbo.HRDesignations AS HRD ON HRD.DesigCode = EO.DesigCode
    WHERE
        ((EO.CCCode BETWEEN @SCCCode AND @ECCCode) 
             OR (@SCCCode IS NULL AND @ECCCode >= EO.CCCode)
             OR (@ECCCode IS NULL AND @SCCCode <= EO.CCCode)
             OR (@SCCCode IS NULL AND @ECCCode IS NULL))
        AND EA.AttendDate BETWEEN @SDate AND @EDate
        AND (EA.Attend IN (SELECT id FROM StrCol2Tab(@Attend)) OR @Attend=''All'' OR @Attend IS NULL)
        AND ((EO.EmpCode IN (SELECT id FROM StrCol2Tab(@EmpCode))) 
             OR @EmpCode = ''All'' OR @EmpCode IS NULL)';

    IF @SortBy = 'D:C:E'
        SET @SQL += ' ORDER BY EA.AttendDate ASC, EO.CCCode ASC, EO.EmpCode ASC';
    ELSE IF @SortBy = 'C:D:E'
        SET @SQL += ' ORDER BY EO.CCCode ASC, EA.AttendDate ASC, EO.EmpCode ASC';
    ELSE IF @SortBy = 'D:E:C'
        SET @SQL += ' ORDER BY EA.AttendDate ASC, EO.EmpCode ASC, EO.CCCode ASC';
    ELSE
        SET @SQL += ' ORDER BY EO.CCCode ASC, EO.EmpCode ASC, EA.AttendDate ASC';

    EXEC sp_executesql @SQL,
        N'@SCCCode VARCHAR(50), @ECCCode VARCHAR(50), @SDate DATE, @EDate DATE, @EmpCode VARCHAR(MAX), @Attend VARCHAR(MAX)',
        @SCCCode = @SCCCode,
        @ECCCode = @ECCCode,
        @SDate = @SDate,
        @EDate = @EDate,
        @EmpCode = @EmpCode,
        @Attend = @Attend;
END
