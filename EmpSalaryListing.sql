USE [CLOUDERP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EmpSalaryListing]
	@SCCCode VARCHAR(50),
	@ECCCode VARCHAR(50)

AS
BEGIN
	SET NOCOUNT ON;
	SELECT CONCAT(EO.EmpCode, ' ', EP.EmpName) AS Employee,
		GLB.BrName,
		HRD.DesigName,
		CONCAT(GLCC.CCCode, ' ', GLCC.CCDescription) AS CCDescription,
		ES.EGrossPay,
		ES.ETotalAllow,
		ES.ENetPay,
		ES.TotalDed,
		ES.EBasicPay,
		ES.EarrearsAllow,
		ES.EConvAllow,
		ES.EEOBIAllow,
		ES.EFixedAllow,
		ES.EfoodAllow,
		ES.EHRAllow,
		ES.EInternetAllow,
		ES.EMedAllow,
		ES.EMobileAllow,
		ES.EOBIDed,
		ES.EOtherAllow,
		ES.EPESSIAllow,
		ES.EPetrolAllow,
		ES.EutilityAllow,
		ES.AdvDed,
		ES.LoanInstDed,
		ES.OverpayDed,
		ES.PFundDed,
		ES.ProfTaxDed,
		ES.TaxDed

	FROM EmpOfficeInfo AS EO
		JOIN EmpPersonalInfo AS EP
		ON EO.EmpCode = EP.EmpCode
		JOIN EmpSalary AS ES
		ON EO.EmpCode = ES.EmpCode
		JOIN GLBranch AS GLB
		ON EO.BrCode = GLB.BrCode
		JOIN GLCostCenter AS GLCC
		ON EO.CCCode = GLCC.CCCode
		JOIN HRDesignations AS HRD
		ON EO.DesigCode = HRD.DesigCode

	WHERE (
        (@SCCCode IS NULL AND @ECCCode IS NULL)
		OR (@SCCCode IS NOT NULL AND @ECCCode IS NULL AND GLCC.CCCode >= @SCCCode)
		OR (@SCCCode IS NULL AND @ECCCode IS NOT NULL AND GLCC.CCCode <= @ECCCode)
		OR (@SCCCode IS NOT NULL AND @ECCCode IS NOT NULL AND GLCC.CCCode BETWEEN @SCCCode AND @ECCCode)
    )
	ORDER BY 
        GLCC.CCCode ASC,
        EO.EmpCode ASC;

END;