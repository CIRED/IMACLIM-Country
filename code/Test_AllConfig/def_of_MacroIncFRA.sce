// ----------------------------- *
// Define the data for the tests *
// ----------------------------- *

/// Parameters of the tests
// Enable TEST_MODE in ImaclimS.sce
TEST_MODE = %F;
// No test mode for these tests


// * ------------------------------------------------------------- *
// * France *
// * ------ *

name_fra = 'France';
iso_fra = 'FRA2018';

//// MacroIncer resolution tests
test_fra_macro.System_Resol = ['Systeme_ProjHomothetic'];
test_fra_macro.study = ['SNBC3_RunChoices3'];
test_fra_macro.Optimization_Resol = ['%T'];
test_fra_macro.SystemOpt_Resol = ['SystemOpt_Static_neokeynesien_multiReport'];
test_fra_macro.Multireport_budget_share = ['Multireport_budget_share_ref', 'Multireport_major_landTransport', 'Multireport_major_property_business'];
test_fra_macro.AGG_type = ['AGG_23TME'];
test_fra_macro.H_DISAGG = ['HH1'];
test_fra_macro.Nb_Iter = ['3'];
test_fra_macro.Macro_nb = ['SNBC3_run3dgt3'];
test_fra_macro.Scenario = ['AMSrun3mixnotebis'];//'AMErun3dgtnote'
test_fra_macro.proj_alpha = ['true'];
test_fra_macro.proj_kappa = ['true'];
test_fra_macro.proj_lambda = ['true'];
test_fra_macro.proj_invest = ['false'];
test_fra_macro.proj_c = ['true'];
test_fra_macro.exports_drive = ['true'];
test_fra_macro.proj_imports = ['false'];
test_fra_macro.proj_exports = ['false'];
test_fra_macro.proj_pY = ['false'];
test_fra_macro.pY_gas_reduced_v2 = ['false'];
test_fra_macro.reindustrialisation_imports_bool = ['false'];
test_fra_macro.reindustrialisation_exports_bool = ['false'];
test_fra_macro.with_sufficiency_behaviour = ["Construction X Chauffage X Gaspillage alimentaire X Achat vehicules neufs X Deplacements X OthEq X Electromenager X OtherManufacturedGoods"];
test_fra_macro.VAR_saving = ['moderate']; //'ref', 'high_2'];
// test_fra_macro.VAR_sigma_M = ['high2'];
// test_fra_macro.coeff_constraint = ['ref','1_10','1_08','1_06','1_04'];
test_fra_macro.VAR_sigma_X = ['threeme'];
test_fra_macro.VAR_sigma_M = ['threeme'];
// test_fra_macro.VAR_sigma_X = ['threeme','low', 'high'];
// test_fra_macro.VAR_sigma_M = ['threeme','low', 'high'];
// test_fra_macro.VAR_sigma_X = ['ref'];
test_fra_macro.Proj_scenario = ['SNBC3_run3totalamsmixc2bis'];
test_fra_macro.Coef_real_wage = ["1"];
// test_fra_macro.Coef_real_wage_dashboard = ["0.5"];
test_fra_macro.skip_calibration = ['True'];


france_macro = new_country(name_fra, iso_fra, test_fra_macro);



// ------------------------- *
// List of countries to test *
// ------------------------- * 

countries = list(france_macro); 
