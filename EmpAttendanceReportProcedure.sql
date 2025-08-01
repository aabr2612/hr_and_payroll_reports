USE [CLOUDERP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EmpAttendanceReport]
    @SDate DATE,
    @EDate DATE,
    @Attend varChar(max)

AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Concat(EP.EmpCode,' ',EP.EmpName) AS Employee,
        EA.AttendDate,

        CASE 
            WHEN EA.Attend = 'Present'
            AND EA.OfficeIn IS NOT NULL
            AND EA.OfficeOut IS NOT NULL THEN
                EA.OfficeIn + CHAR(13) + CHAR(10) + EA.OfficeOut
            ELSE
                LEFT(EA.Attend, 1)
        END AS Attendance,

        Concat(GLCC.CCCode,' ',GLCC.CCDescription) as CCDescription,
        GLB.BrName,
        EO.BrCode,
        EA.OfficeIn,
        EA.OfficeOut

    FROM dbo.EmpOfficeInfo AS EO
        INNER JOIN dbo.EmpPersonalInfo AS EP
        ON EP.EmpCode = EO.EmpCode
        INNER JOIN dbo.EmpAttendance AS EA
        ON EA.EmpCode = EO.EmpCode
        INNER JOIN dbo.GLCostCenter AS GLCC
        ON GLCC.CCCode = EO.CCCode
        INNER JOIN dbo.GLBranch AS GLB
        ON GLB.BrCode = EO.BrCode

    WHERE
        (EA.Attend IN (select id
        from StrCol2Tab(@Attend)) OR @Attend IS NULL)
        AND EA.AttendDate BETWEEN @SDate AND @EDate

    ORDER BY 
        EO.CCCode ASC,
        EO.EmpCode ASC,
        EA.AttendDate ASC;
END
