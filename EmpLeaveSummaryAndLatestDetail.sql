USE [CLOUDERP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [EmpLeaveSummaryAndLatestDetail]
    @EmpCode VARCHAR(5)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ELE.Allowed,
        ELE.Balance,
        ELE.Availed,
        ELE.Earned,
        ELE.PrevBal,
        LT.LTypeDesc,
        ELT.LatestLeaveDate,
        ELT.LatestDaysNo
    FROM EmpLeaveEnt AS ELE
    JOIN LeaveTypes AS LT
        ON ELE.LTypeCode = LT.LTypeCode
    JOIN GLFiscalYear AS GLFY
        ON ELE.FYCode = GLFY.FYCode
    OUTER APPLY (
        SELECT TOP 1 
            EL.LeaveDate AS LatestLeaveDate,
            RTRIM(CAST(CAST(EL.DaysNo AS FLOAT) AS VARCHAR)) AS LatestDaysNo
        FROM EmpLeaves AS EL
        WHERE EL.LeaveCode = ELE.LTypeCode
          AND EL.EmpCode = ELE.EmpCode
        ORDER BY EL.LeaveDate DESC
    ) AS ELT
    WHERE ELE.EmpCode = @EmpCode 
      AND YEAR(GLFY.FYStartDate) = YEAR(GETDATE());

    SELECT TOP 1
        EO.EmpCode,
        EP.EmpName,
        GLB.BrName,
        HRD.DesigName,
        GLCC.CCDescription,
        EL.LeaveReqNo,
        EL.LeaveCode,
        EL.LeaveDate,
        EL.FromDate,
        EL.ToDate,
        EL.DaysNo,
        EL.AdminRemarks,
        LT.LTypeDesc
    FROM dbo.EmpOfficeInfo AS EO
    INNER JOIN dbo.EmpPersonalInfo AS EP
        ON EP.EmpCode = EO.EmpCode
    INNER JOIN dbo.GLBranch AS GLB
        ON GLB.BrCode = EO.BrCode
    INNER JOIN dbo.HRDesignations AS HRD
        ON HRD.DesigCode = EO.DesigCode
    INNER JOIN dbo.GLCostCenter AS GLCC
        ON GLCC.CCCode = EO.CCCode
    INNER JOIN dbo.EmpLeaves AS EL
        ON EL.EmpCode = EO.EmpCode
    INNER JOIN dbo.LeaveTypes AS LT
        ON LT.LTypeCode = EL.LeaveCode
    WHERE 
        EO.EmpCode = @EmpCode
        AND YEAR(EL.LeaveDate) = YEAR(GETDATE())
    ORDER BY EL.LeaveDate DESC;
END
