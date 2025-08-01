USE [CLOUDERP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EmpAttendanceSummary]
    @SDate DATE,
    @EDate DATE,
    @Attend VARCHAR(MAX)

AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        EP.EmpName AS Employee,
        GLCC.CCDescription,
        GLCC.CCCode,
        GLB.BrName,
        EO.BrCode,

        SUM(CASE WHEN EA.Attend = 'Present' THEN 1 ELSE 0 END) AS Presents,
        SUM(CASE WHEN EA.Attend = 'Absent' THEN 1 ELSE 0 END) AS Absents,
        SUM(CASE WHEN EA.Attend = 'Leave' THEN 1 ELSE 0 END) AS Leaves,
        SUM(CASE WHEN EA.Attend = 'Holiday' THEN 1 ELSE 0 END) AS Holidays,
        SUM(CASE WHEN EA.Attend = 'Gazetted' THEN 1 ELSE 0 END) AS GazettedLeaves

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

    GROUP BY 
        EP.EmpName,
        GLCC.CCDescription,
        GLCC.CCCode,
        GLB.BrName,
        EO.BrCode

    ORDER BY 
        GLCC.CCCode ASC,
        EP.EmpName ASC;
END
