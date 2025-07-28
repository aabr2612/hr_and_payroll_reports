USE [CLOUDERP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[EmpLeavesRecord]
	@SDate DATE,
	@EDate DATE

AS
BEGIN
SELECT CONCAT(EO.EmpCode,' ',EP.EmpName) AS Employee,
	CONCAT(GLCC.CCCode,' ',GLCC.CCDescription) AS CCCode,
	GLB.BrName,
	HRD.DesigName,
	EL.FromDate,
	EL.ToDate,
	RTRIM(CAST(CAST(EL.DaysNo AS FLOAT) AS VARCHAR)) AS DaysNo,
	EL.LeaveReqNo,
	LT.LTypeDesc,
	EL.LeaveDate,
	RTRIM(CAST(CAST(EL.RemBal AS FLOAT) AS VARCHAR)) AS RemBal,
	RTRIM(CAST(CAST(EL.PrevBal AS FLOAT) AS VARCHAR)) AS PrevBal,
	EL.Status


FROM EmpOfficeInfo AS EO 
JOIN EmpPersonalInfo AS EP
ON EO.EmpCode = EP.EmpCode
JOIN EmpLeaves AS EL
ON EO.EmpCode = EL.EmpCode
JOIN HRDesignations AS HRD
ON EO.DesigCode = HRD.DesigCode
JOIN GLBranch AS GLB
ON EO.BrCode = GLB.BrCode
JOIN GLCostCenter AS GLCC
ON EO.CCCode = GLCC.CCCode
JOIN LeaveTypes AS LT
On EL.LeaveCode = LT.LTypeCode

WHERE EL.LeaveDate BETWEEN @SDate AND @EDate

ORDER BY 
	EO.EmpCode ASC,
	EL.LeaveDate ASC

END;