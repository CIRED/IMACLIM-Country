/////////////////////////////////////////////// TRANSFERT MA PRIME RENOV  /////////////////////////////////////////////////////////////////////////////////////
MPR_share = 0;
Bonus_vehicules_share = 0;



//////////////////////////////////////////////// WAGE CURVE  /////////////////////////////////////////////////////////////////////////////////////
// parameters.Coef_real_wage = strtod(Coef_real_wage_dashboard);
// parameters.sigma_omegaU = strtod(sigma_omegaU_dashboard);


//////////////////////////////////////////////// POUR SIMULATIONS PAS A PAS  /////////////////////////////////////////////////////////////////////////////////////

// TOCLEAN
// Productivite du travail quand Demographic_shift est désactivé : on met les valeurs qui sont normalement calculees dans macro_framework.sce
// Desactiver les projections qui sont toujours mises a %T dans projection_scenario.csv
if proj_alpha == 'false'
    Proj_Vol.alpha.apply_proj = %F;
end 

if proj_c == 'false'
    Proj_Vol.C.apply_proj = %F;
end 

if proj_kappa == 'false' | Proj_scenario == 'SNBC3test_run31' | Proj_scenario == 'SNBC3test_run32' | Proj_scenario == 'SNBC3test_run33' | Proj_scenario == 'SNBC3test_run34' | Proj_scenario == 'SNBC3test_irun31' | Proj_scenario == 'SNBC3test_irun32'| Proj_scenario == 'SNBC3test_irun33' | Proj_scenario == 'SNBC3test_irun34' | Proj_scenario == 'SNBC3test_irun38' | Proj_scenario == 'SNBC3test_irun39' | Proj_scenario == 'SNBC3test_irun310' | Proj_scenario == 'SNBC3test_irun312' | Proj_scenario == 'SNBC3test_irun313' | Proj_scenario == 'SNBC3test_irun314' | Proj_scenario == 'SNBC3test_irun316' | Proj_scenario == 'SNBC3test_irun321' 
    Proj_Vol.kappa.apply_proj = %F;
end

if proj_lambda == 'false' 
    Proj_Vol.lambda.apply_proj = %F;
end

if proj_imports == 'false'
    Proj_Vol.M_Y.apply_proj = %F;
end

if proj_exports == 'false'
    Proj_Vol.X.apply_proj = %F;
end

if proj_invest == 'false'
    Proj_Vol.I.apply_proj = %F;
end

if proj_pY == 'false'
    Proj_Vol.pY.apply_proj = %F;
end

if proj_spemarg_rates_IC == 'false'
    Proj_Vol.SpeMarg_rates_IC.apply_proj = %F;
end

//////////////////////////////////////////////// EXPORTATIONS  ///////////////////////////////////////////////////////////////////////////////

if  exports_drive=='true' 

	parameters.delta_X_parameter(1:20) = delta_X_file(1:20,time_step)';
    parameters.delta_X_parameter(22:23) = delta_X_file(22:23,time_step)';

end

if  imports_drive=='true' 

	parameters.delta_M_parameter(1:20) = delta_M_file(1:20,time_step)';
    parameters.delta_M_parameter(22:23) = delta_M_file(22:23,time_step)';

end

//////////////////////////////////////////////// EMISSIONS  /////////////////////////////////////////////////////////////////////////////////////

// On réduit les facteurs d'émissions selon la proportion de bioénergie utilisée
if emissions_bioenergy == 'True' then
    Deriv_Exogenous.Emission_Coef_IC = Emission_Coef_IC;
	bioenergy_proportions_filename = 'bioenergy_proportions_' + Scenario; // Creation of a string like "bioenergy_proportions_AME"
	bioenergy_proportions = evstr(bioenergy_proportions_filename); // Get the value of the var named bioenergy_proportions_AME
	bioenergy_proportions = repmat(bioenergy_proportions(:,time_step)', nb_Sectors, 1)'; // Reproduction of the column corresponding to time_step
	Deriv_Exogenous.Emission_Coef_IC(Indice_EnerSect, :) = BY.Emission_Coef_IC(Indice_EnerSect, :) .* (ones(5 , nb_Sectors) - bioenergy_proportions); // Reducing the emissions factors by the proportions of bioenergy
    Deriv_Exogenous.Emission_Coef_C = Emission_Coef_C;
    bioenergy_proportions_C = evstr('bioenergy_proportions_' + Scenario); // rechargement de la matrice complète
    bioenergy_proportions_C = repmat(bioenergy_proportions_C(:,time_step)', nb_Households, 1)'; // 5 x nb_Households
    Deriv_Exogenous.Emission_Coef_C(Indice_EnerSect, :) = BY.Emission_Coef_C(Indice_EnerSect, :) .* (ones(5, nb_Households) - bioenergy_proportions_C);
end

//////////////////////////////////////////////// CONTROLE pY GAZ PAR RAPPORT A pM GAZ  /////////////////////////////////////////////////////////////////////////////////////
//////////////////////// INACTIF ET NON TESTE - BAISSER LA TICPE  /////////////////////////////////////////////////////////////////////////////////////
// REDUCING THE TICPE TAX BY THE PROPORTION OF BIOENERGY - ONLY FOR LIQUID_FUELS
//TOCLEAN
if 0 & ticpe_bioenergy == 'True' then
    bioenergy_proportions_filename = 'bioenergy_proportions_' + Scenario; // Creation of a string like "bioenergy_proportions_AME"
    bioenergy_proportions = evstr(bioenergy_proportions_filename); // Get the value of the var named bioenergy_proportions_AME
    bioenergy_proportion_liquid_fuels = bioenergy_proportions(2,time_step); // Select liquid_fuels' value for time_step

    bioenergy_taxe_rate = 0.33 * Energy_Tax_rate_IC(2); // We suppose bioenergy is 3 times less taxed

    Deriv_Exogenous.Energy_Tax_rate_IC = Energy_Tax_rate_IC;
    Deriv_Exogenous.Energy_Tax_rate_IC(2) = bioenergy_taxe_rate * bioenergy_proportion_liquid_fuels + Energy_Tax_rate_IC(2) * (1-bioenergy_proportion_liquid_fuels); // Weighted calculation
end


//////////////////////////////////////////////// Coeff constraint  ///////////////////////////////////////////////////////////////////////////////

if coeff_constraint=="ref"

	Deriv_Exogenous.coeff_constraint = 1.127633389;

elseif coeff_constraint=="1_10"

	Deriv_Exogenous.coeff_constraint = 1.10;

elseif coeff_constraint=="1_08"

	Deriv_Exogenous.coeff_constraint = 1.08;

elseif coeff_constraint=="1_06"

	Deriv_Exogenous.coeff_constraint = 1.06;

elseif coeff_constraint=="1_04"

	Deriv_Exogenous.coeff_constraint = 1.04;

end

//////////////////////////////////////////////////// Import-export price elasticity  //////////////////////////////////////////////////////////////////////

if VAR_sigma_M=="high2"
	Deriv_Exogenous.sigma_M = [0,0,0,0,0,2.85,2.85,2.85,2.85,2.85,2.85,2.85,2.85,2.85,2.85,2.85,0,0,0,2.85,0,2.85,2.85];
// elseif VAR_sigma_M=="high1"
// 	Deriv_Exogenous.sigma_M = [0,0,0,0,0,2.375,2.375,2.375,2.375,2.375,2.375,2.375,2.375,2.375,2.375,2.375,0,0,0,2.375,0,2.375,2.375];
// elseif VAR_sigma_M=="ref"
// 	Deriv_Exogenous.sigma_M = [0,0,0,0,0,1.9,1.9,1.9,1.9,1.9,1.9,1.9,1.9,1.9,1.9,1.9,0,0,0,1.9,0,1.9,1.9];
// elseif VAR_sigma_M=="low1"
// 	Deriv_Exogenous.sigma_M = [0,0,0,0,0,1.425,1.425,1.425,1.425,1.425,1.425,1.425,1.425,1.425,1.425,1.425,0,0,0,1.425,0,1.425,1.425];
// elseif VAR_sigma_M=="low2"
//     Deriv_Exogenous.sigma_M = [0,0,0,0,0,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0.95,0,0,0,0.95,0,0.95,0.95];
// elseif VAR_sigma_M=="old"
//     Deriv_Exogenous.sigma_M = [0,0,0,0,0,1.2,1.2,1.2,1.2,1.2,1.2,1.2,1.2,1.2,1.2,1.2,0,0,0,1.2,0,1.2,1.2];
// elseif VAR_sigma_M=="gtap"
//     Deriv_Exogenous.sigma_M = [0,0,0,0,0,2.95,4.2,2.9,2.9,3.3,2.95,2.8,4.05,4.4,2.0,3.75,0,0,0,2.5,0,1.9,1.9];
elseif VAR_sigma_M=="threeme"
    Deriv_Exogenous.sigma_M = [0,0,0,0,0,0.48,0.48,0.48,0.48,0.48,0.48,0.48,0.48,0.48,0.48,0.48,0,0,0,0.48,0,0.69,0.69];
// elseif VAR_sigma_M=="low"
//     Deriv_Exogenous.sigma_M = [0,0,0,0,0,0.43,0.43,0.43,0.43,0.43,0.43,0.43,0.43,0.43,0.43,0.43,0,0,0,0.43,0,0.62,0.62];
elseif VAR_sigma_M=="high"
    Deriv_Exogenous.sigma_M = [0,0,0,0,0,0.53,0.53,0.53,0.53,0.53,0.53,0.53,0.53,0.53,0.53,0.53,0,0,0,0.53,0,0.76,0.76];
// elseif VAR_sigma_M=="max"
//     Deriv_Exogenous.sigma_M = [0,0,0,0,0,0.72,0.72,0.72,0.72,0.72,0.72,0.72,0.72,0.72,0.72,0.72,0,0,0,0.72,0,0.72,0.72];
// elseif VAR_sigma_M=="note"
//     Deriv_Exogenous.sigma_M = [0,0,0,0,0,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0,0,0,0.8,0,0.8,0.8];
end

if VAR_sigma_X=="high2"
    Deriv_Exogenous.sigma_X = [0,0,0,0,0,0.63,0.63,0.63,0.63,0.63,0.63,0.63,0.63,0.63,0.63,0.63,0,0,0,0.63,0,0.63,0.63];
// elseif VAR_sigma_X=="high1"
//     Deriv_Exogenous.sigma_X = [0,0,0,0,0,0.525,0.525,0.525,0.525,0.525,0.525,0.525,0.525,0.525,0.525,0.525,0,0,0,0.525,0,0.525,0.525];;
// elseif VAR_sigma_X=="ref"
//     Deriv_Exogenous.sigma_X = [0,0,0,0,0,0.42,0.42,0.42,0.42,0.42,0.42,0.42,0.42,0.42,0.42,0.42,0,0,0,0.42,0,0.42,0.42];
// elseif VAR_sigma_X=="low1"
//     Deriv_Exogenous.sigma_X = [0,0,0,0,0,0.315,0.315,0.315,0.315,0.315,0.315,0.315,0.315,0.315,0.315,0.315,0,0,0,0.315,0,0.315,0.315];;
// elseif VAR_sigma_X=="low2"
//     Deriv_Exogenous.sigma_X = [0,0,0,0,0,0.21,0.21,0.21,0.21,0.21,0.21,0.21,0.21,0.21,0.21,0.21,0,0,0,0.21,0,0.21,0.21];;
// elseif VAR_sigma_X=="minx"
//      Deriv_Exogenous.sigma_X = [0,0,0,0,0,0.22,0.22,0.22,0.22,0.22,0.22,0.22,0.22,0.22,0.22,0.22,0,0,0,0.22,0,0.22,0.0];
// elseif VAR_sigma_X=="old"
//     Deriv_Exogenous.sigma_X = [0,0,0,0,0,0.42,0.42,0.42,0.42,0.42,0.42,0.42,0.42,0.42,0.42,0.42,0,0,0,0.42,0,0.42,0];
elseif VAR_sigma_X=="threeme"
    Deriv_Exogenous.sigma_X = [0,0,0,0,0,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0,0,0,0.8,0,0.8,0.8];
// elseif VAR_sigma_X=="low"
//     Deriv_Exogenous.sigma_X = [0,0,0,0,0,0.72,0.72,0.72,0.72,0.72,0.72,0.72,0.72,0.72,0.72,0.72,0,0,0,0.72,0,0.72,0.72];
elseif VAR_sigma_X=="high"
    Deriv_Exogenous.sigma_X = [0,0,0,0,0,0.88,0.88,0.88,0.88,0.88,0.88,0.88,0.88,0.88,0.88,0.88,0,0,0,0.88,0,0.88,0.88];
// elseif VAR_sigma_X=="max"
//     Deriv_Exogenous.sigma_X = [0,0,0,0,0,1.1,1.1,1.1,1.1,1.1,1.1,1.1,1.1,1.1,1.1,1.1,0,0,0,1.1,0,1.1,1.1];
end

if VAR_sigma_omegaU=="-0.1"
	parameters.sigma_omegaU = -0.1;
// elseif VAR_sigma_omegaU=="-0.6"
// 	parameters.sigma_omegaU = -0.6;
// elseif VAR_sigma_omegaU=="-1.2"
// 	parameters.sigma_omegaU = -1.2;
// elseif VAR_sigma_omegaU=="-1.8"
// 	parameters.sigma_omegaU = -1.8;
// elseif VAR_sigma_omegaU=="-2.4"
// 	parameters.sigma_omegaU = -2.4;
// elseif VAR_sigma_omegaU=="-3.0"
// 	parameters.sigma_omegaU = -3.0;
elseif VAR_sigma_omegaU=="-3.6"
	parameters.sigma_omegaU = -3.6;
elseif VAR_sigma_omegaU=="-0.01"
	parameters.sigma_omegaU = -0.01;
// elseif VAR_sigma_omegaU=="-0.5"
// 	parameters.sigma_omegaU = -0.5;
// elseif VAR_sigma_omegaU=="-1.0"
// 	parameters.sigma_omegaU = -1.0;
end

if Coef_real_wage=="1"
	parameters.Coef_real_wage = 1;
elseif Coef_real_wage=="0.5"
    parameters.Coef_real_wage = 0.5;
elseif Coef_real_wage=="0"
    parameters.Coef_real_wage = 0;
end

//////////////////////////////////////////////////// Saving rate  //////////////////////////////////////////////////////////////////////
// Here we try to force the consumption of the households throught the savings rate. The saving rate is defined as the ratio of consumption to disposable income. 
// By modifiying saving rate, we force the consumption


// if  VAR_saving=="ref"
//     if time_step==1 then
//         Deriv_Exogenous.Household_saving_rate = [-0.1544285, 0.1625142, 0.1563019, 0.1648821, 0.1872008, 0.2094751, 0.2101968, 0.185525, 0.1567789, 0.1520701];
//     elseif time_step==2 then
//         Deriv_Exogenous.Household_saving_rate = [-0.1168081, 0.1902968, 0.182118, 0.1877537, 0.2086237, 0.2274867, 0.2273128, 0.2007818, 0.173253, 0.16626];
//     elseif time_step==3 then
//         Deriv_Exogenous.Household_saving_rate = [-0.0804373, 0.2167876, 0.2066028, 0.2093052, 0.2287751, 0.244324, 0.2433221, 0.2150417, 0.1886796, 0.1794458];
//     elseif time_step==4 then
//         Deriv_Exogenous.Household_saving_rate = [-0.054427, 0.2438089, 0.2374759, 0.2381785, 0.2557806, 0.2663337, 0.2664508, 0.2371913, 0.2147391, 0.2022394];
//     end
// end


if VAR_saving=="ref"
    if time_step==1 then
        Deriv_Exogenous.Household_saving_rate = [-0.1544285, 0.16251424, 0.1563019, 0.16488211, 0.18720079, 0.20947509, 0.21019675, 0.18552499, 0.15677891, 0.15207012];
    elseif time_step==2 then
        Deriv_Exogenous.Household_saving_rate = [-0.1168081, 0.19029681, 0.18211798, 0.18775369, 0.20862372, 0.22748673, 0.22731284, 0.20078181, 0.17325298, 0.16626003];
    elseif time_step==3 then
        Deriv_Exogenous.Household_saving_rate = [-0.0804373, 0.21678762, 0.20660277, 0.2093052, 0.22877512, 0.24432397, 0.24332214, 0.21504167, 0.18867963, 0.17944581];
    elseif time_step==4 then
        Deriv_Exogenous.Household_saving_rate = [-0.054427, 0.24380895, 0.23747592, 0.23817847, 0.25578059, 0.26633375, 0.2664508, 0.23719129, 0.21473907, 0.20223941];
    end
end


if  VAR_saving=="moderate"
    if time_step==1 then
        HH_saving_rate_ref = [-0.1544285, 0.16251424, 0.1563019, 0.16488211, 0.18720079, 0.20947509, 0.21019675, 0.18552499, 0.15677891, 0.15207012];
        HH_saving_rate_sufficiency = [-0.096344451, 0.209153773, 0.212478282, 0.221304488, 0.242693935, 0.264401184, 0.267864935, 0.247386523, 0.224416962, 0.217652413];
        Deriv_Exogenous.Household_saving_rate = (HH_saving_rate_ref + HH_saving_rate_sufficiency)/2;

    elseif time_step==2 then
        HH_saving_rate_ref = [-0.1168081, 0.19029681, 0.18211798, 0.18775369, 0.20862372, 0.22748673, 0.22731284, 0.20078181, 0.17325298, 0.16626003];
        HH_saving_rate_sufficiency = [-0.079071697, 0.222903659, 0.227141892, 0.235528657, 0.256479753, 0.277114764, 0.280210481, 0.260033569, 0.23794509, 0.230393389];
        Deriv_Exogenous.Household_saving_rate = (HH_saving_rate_ref + HH_saving_rate_sufficiency)/2;

    elseif time_step==3 then
        HH_saving_rate_ref = [-0.0804373, 0.21678762, 0.20660277, 0.2093052, 0.22877512, 0.24432397, 0.24332214, 0.21504167, 0.18867963, 0.17944581];
        HH_saving_rate_sufficiency = [-0.061757087, 0.236573373, 0.241626709, 0.249426059, 0.269896806, 0.289379048, 0.292118678, 0.272186766, 0.250964242, 0.242589558];
        Deriv_Exogenous.Household_saving_rate = (HH_saving_rate_ref + HH_saving_rate_sufficiency)/2;

    elseif time_step==4 then
        HH_saving_rate_ref = [-0.054427, 0.24380895, 0.23747592, 0.23817847, 0.25578059, 0.26633375, 0.2664508, 0.23719129, 0.21473907, 0.20223941];
        HH_saving_rate_sufficiency = [-0.055774506, 0.249603027, 0.259484236, 0.266979586, 0.286617352, 0.30323724, 0.306470915, 0.286505504, 0.268034023, 0.257707994];
        Deriv_Exogenous.Household_saving_rate = (HH_saving_rate_ref + HH_saving_rate_sufficiency)/2;
    end
end


if VAR_saving=="with_full_sufficiency in 2030"
    if time_step==1 then
        Deriv_Exogenous.Household_saving_rate = [-0.096344451, 0.209153773, 0.212478282, 0.221304488, 0.242693935, 0.264401184, 0.267864935, 0.247386523, 0.224416962, 0.217652413];
    elseif time_step==2 then
        Deriv_Exogenous.Household_saving_rate = [-0.079071697, 0.222903659, 0.227141892, 0.235528657, 0.256479753, 0.277114764, 0.280210481, 0.260033569, 0.23794509, 0.230393389];
    elseif time_step==3 then
        Deriv_Exogenous.Household_saving_rate = [-0.061757087, 0.236573373, 0.241626709, 0.249426059, 0.269896806, 0.289379048, 0.292118678, 0.272186766, 0.250964242, 0.242589558];
    elseif time_step==4 then
        Deriv_Exogenous.Household_saving_rate = [-0.055774506, 0.249603027, 0.259484236, 0.266979586, 0.286617352, 0.30323724, 0.306470915, 0.286505504, 0.268034023, 0.257707994];
    end
end


// if  VAR_saving=="with_full_sufficiency"
//     if time_step==1 then
//         Deriv_Exogenous.Household_saving_rate = [-0.1346837, 0.1783317, 0.1758101, 0.1845749, 0.2066004, 0.2287687, 0.2305456, 0.2075212, 0.1809076, 0.1755088];
//     elseif time_step==2 then
//         Deriv_Exogenous.Household_saving_rate = [-0.0976145, 0.206744, 0.2048569, 0.2117452, 0.2325893, 0.252167, 0.2537455, 0.2303864, 0.2056889, 0.198369];
//     elseif time_step==3 then
//         Deriv_Exogenous.Household_saving_rate = [-0.0636392, 0.2330381, 0.2319223, 0.2371721, 0.2569538, 0.2741884, 0.2756696, 0.2522343, 0.2292868, 0.2202532];
//     elseif time_step==4 then
//         Deriv_Exogenous.Household_saving_rate = [-0.038439, 0.2613402, 0.2666537, 0.2711304, 0.2895635, 0.3030323, 0.3059347, 0.2832149, 0.264474, 0.2527917];
//     end
// end

// TO DELETE 
// if  VAR_saving=="ref +1%"
//     if time_step==1 then
//         Deriv_Exogenous.Household_saving_rate = 0.1632678 + 0.01;
//     elseif time_step==2 then
//         Deriv_Exogenous.Household_saving_rate = 0.1962235 + 0.01;
//     elseif time_step==3 then
//         Deriv_Exogenous.Household_saving_rate = 0.2187141 + 0.01;
//     end
// end

// if  VAR_saving=="ref +2%"
//     if time_step==1 then
//         Deriv_Exogenous.Household_saving_rate = 0.1632678 + 0.02;
//     elseif time_step==2 then
//         Deriv_Exogenous.Household_saving_rate = 0.1962235 + 0.02;
//     elseif time_step==3 then
//         Deriv_Exogenous.Household_saving_rate = 0.2187141 + 0.02;
//     end
// end


// if national_preference=="True"
//     // Secteur automobile: on réduit les importations des voitures étrangères de 50% (On favorise le made in france)
// 	Proj_Vol.M.val(12) = Proj_Vol.M.val(12)*0.5;

// elseif national_preference=="False"
//     // Pas de préference nationale: on garde les valeurs de références
//     Proj_Vol.M.val(12) = Proj_Vol.M.val(12);
// end

//////////////////////////////////////// MULTI-REPORT SCENARIO: THE EXTRA SAVINGS ARE REPORTED IN DIFFERENT SECTORS  //////////////////////////////////////////////////////////////////////
// In this scenario, we suppose that a part of the saving made with behaviour change is reported in three different sectors (land transport, property and business services, composite) according to the shares defined below. 
//The rest of the saving is not consummed and lead to an increase of the saving rate of the households

if SystemOpt_Resol== 'SystemOpt_Static_neokeynesien_multiReport'
    if Multireport_budget_share=="Multireport_budget_share_ref_AMS"
        share_landtransport = 0.0314357;
        share_property_business = 0.3789194;
        share_composite = 0.5896448;
    elseif Multireport_budget_share=="Multireport_major_landTransport"
        share_landtransport = 0.036283;
        share_property_business = 0.344482;
        share_composite = 0.6192235;
    elseif Multireport_budget_share=="Multireport_major_property_business"
        share_landtransport = 0.029820;
        share_property_business = 0.413357;
        share_composite = 0.556823;
    elseif Multireport_budget_share=="Multireport_major_property_business_v2"
        share_landtransport = 0.029520;
        share_property_business = 0.413357;
        share_composite = 0.557123;
    elseif Multireport_budget_share=="proportion_report_savings_moderate"
        share_landtransport = 0.0298200;
        share_property_business = 0.3444819;
        share_composite = 0.6256981;
    end
end





//////////////////////////////////////////////////// SECOND SUFFICIENCY CHOC FOR 10 HOUSEHOLDS  //////////////////////////////////////////////////////////////////////
// In that scenario we reduce exogenously the consumption of 6 highest households. We suppose that the consumption of 6 highest households in 2050 is equal to the consumption of the household D4 in the different sector studied
// The reduction of consumption by household is defined in the 'HH_consumption_reduction' in the folder AMS2026mesures_h10

// Reduction de la consommation des ménages en 2030
if time_step==1
    if Scenario=="AMS2026mesures_h10"
        // Case where all the consumptions of H5-H10 is equal to the consumption of H4
        if with_sufficiency_behaviour == "Consumption of H4 for H5-H6 in 2050"
            Proj_Vol.C.val = Proj_Vol.C.val .* (1 + HH_consumption_reduction_1);
        end

        // This scenario is an equivalent choc of the scenario "Consumption of H4 for H5-H6 in 2050" but homogenously distributed among all households
        if with_sufficiency_behaviour == "Choc of H4 homogenously distributed"
            Proj_Vol.C.val = Proj_Vol.C.val .* (1 + HH_consumption_homogenous_reduction_1);
        end
    end
end

// Reduction de la consommation des ménages  en 2035
if time_step==2
    if Scenario=="AMS2026mesures_h10"
        // Case where all the consumptions of H5-H10 is equal to the consumption of H4
        if with_sufficiency_behaviour == "Consumption of H4 for H5-H6 in 2050"
            Proj_Vol.C.val = Proj_Vol.C.val .* (1 + HH_consumption_reduction_2);
        end
    
        // This scenario is an equivalent choc of the scenario "Consumption of H4 for H5-H6 in 2050" but homogenously distributed among all households
        if with_sufficiency_behaviour == "Choc of H4 homogenously distributed"
            Proj_Vol.C.val = Proj_Vol.C.val .* (1 + HH_consumption_homogenous_reduction_2);
        end
    end
end

// Reduction de la consommation des ménages en 2040
if time_step==3
    if Scenario=="AMS2026mesures_h10"
        if with_sufficiency_behaviour == "Consumption of H4 for H5-H6 in 2050"
            Proj_Vol.C.val = Proj_Vol.C.val .* (1 + HH_consumption_reduction_3);
        end

        // This scenario is an equivalent choc of the scenario "Consumption of H4 for H5-H6 in 2050" but homogenously distributed among all households
        if with_sufficiency_behaviour == "Choc of H4 homogenously distributed"
            Proj_Vol.C.val = Proj_Vol.C.val .* (1 + HH_consumption_homogenous_reduction_3);
        end
    end
end

// Reduction de la consommation des ménages en 2050
if time_step==4
    if Scenario=="AMS2026mesures_h10"
        if with_sufficiency_behaviour == "Consumption of H4 for H5-H6 in 2050"
            Proj_Vol.C.val = Proj_Vol.C.val .* (1 + HH_consumption_reduction_4);
        end

        // This scenario is an equivalent choc of the scenario "Consumption of H4 for H5-H6 in 2050" but homogenously distributed among all households
        if with_sufficiency_behaviour == "Choc of H4 homogenously distributed"
            Proj_Vol.C.val = Proj_Vol.C.val .* (1 + HH_consumption_homogenous_reduction_4);
        end
    end
end






//////////////////////////////////////////////////// First sufficiency choc  //////////////////////////////////////////////////////////////////////
// In that scenario we reduce exogenously the consumption of the households based on the hypothesis of the sufficiency scenario S1 of ADEME

if time_step==1
    if Scenario=="AMSrun3mixnote" | Scenario=="AMSrun3mixnotebis" | Scenario=="AMS2026mesures_h10"
        if with_sufficiency_behaviour=="Sufficiency Choc S1"
            ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -72% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -3% dans le logement
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22*(1-0.03*12/32) + Proj_Vol.C.val(2,:)*0.78*(1-0.72*12/32);

            // Gas consumption: -3% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3,:) = Proj_Vol.C.val(3,:)*(1-0.03*12/32);

            // Coal consumption: -3% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4,:) = Proj_Vol.C.val(4,:)*(1-0.03*12/32);

            // Electricity consumption: -3% de la consommation du logement (94% de la consommation électricité issue du logement) + -72% de la consommation du transport (6% de la consommation d'electricité pour le transport)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*0.94*(1-0.03*12/32) + Proj_Vol.C.val(5,:)*0.06*(1-0.72*12/32);

            ///// CHOC VEHICULES NEUFS ////////
            // Secteur automobile: -54% d’achats de véhicules neufs 
            Proj_Vol.C.val(12,:) = Proj_Vol.C.val(12,:)*(1-0.54*12/32);

            ///// CHOC BIENS MANUFACTURES ////////
            // Secteur OthEq: -10% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13,:) = Proj_Vol.C.val(13,:)*(1-0.1*12/32);

            // Secteur Electroménager: -66% de consommation électroménager
            Proj_Vol.C.val(14,:) = Proj_Vol.C.val(14,:)*(1-0.66*12/32);
            
            ///// CHOC ALIMENTATION /////
            // Alimentation: -11% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15,:) = Proj_Vol.C.val(15,:)*(1-0.11*12/32);

            // Secteur OtherManufacturedGoods: -9% de consommation de vêtements, autres biens manufacturés,...
            Proj_Vol.C.val(16,:) = Proj_Vol.C.val(16,:)*(1-0.09*12/32);

            ///// CHOC TRANSPORT /////
            // Secteur LandTransport: -12% des déplacements en bus et train
            Proj_Vol.C.val(17,:) = Proj_Vol.C.val(17,:)*(1-0.12*12/32);

            // Secteur AirTransport: -79% de la consommation de transport aérien
            Proj_Vol.C.val(19,:) = Proj_Vol.C.val(19,:)*(1-0.79*12/32);

            // Agriculture: -3% de la production agricole du à la réduction du gaspillage alimentaire
            Proj_Vol.C.val(20,:) = Proj_Vol.C.val(20,:)*(1-0.03*12/32);

            //////  CHOC CONSTRUCTION ////////
            // Construction: -51% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21,:) = Proj_Vol.C.val(21,:)*(1-0.51*12/32);

        end
    end
end


if time_step==2
    if Scenario=="AMSrun3mixnote" | Scenario=="AMSrun3mixnotebis" | Scenario=="AMS2026mesures_h10"
        if with_sufficiency_behaviour=="Sufficiency Choc S1"
            ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -72% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -3% dans le logement
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22*(1-0.03*17/32) + Proj_Vol.C.val(2,:)*0.78*(1-0.72*17/32);

            // Gas consumption: -3% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3,:) = Proj_Vol.C.val(3,:)*(1-0.03*17/32);

            // Coal consumption: -3% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4,:) = Proj_Vol.C.val(4,:)*(1-0.03*17/32);

            // Electricity consumption: -3% de la consommation du logement (94% de la consommation électricité issue du logement) + -72% de la consommation du transport (6% de la consommation d'electricité pour le transport)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*0.94*(1-0.03*17/32) + Proj_Vol.C.val(5,:)*0.06*(1-0.72*17/32);

            ///// CHOC VEHICULES NEUFS ////////
            // Secteur automobile: -54% d’achats de véhicules neufs 
            Proj_Vol.C.val(12,:) = Proj_Vol.C.val(12,:)*(1-0.54*17/32);

            ///// CHOC BIENS MANUFACTURES ////////
            // Secteur OthEq: -10% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13,:) = Proj_Vol.C.val(13,:)*(1-0.1*17/32);

            // Secteur Electroménager: -66% de consommation électroménager
            Proj_Vol.C.val(14,:) = Proj_Vol.C.val(14,:)*(1-0.66*17/32);
            
            ///// CHOC ALIMENTATION /////
            // Alimentation: -11% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15,:) = Proj_Vol.C.val(15,:)*(1-0.11*17/32);

            // Secteur OtherManufacturedGoods: -9% de consommation de vêtements, autres biens manufacturés,...
            Proj_Vol.C.val(16,:) = Proj_Vol.C.val(16,:)*(1-0.09*17/32);

            ///// CHOC TRANSPORT /////
            // Secteur LandTransport: -12% des déplacements en bus et train
            Proj_Vol.C.val(17,:) = Proj_Vol.C.val(17,:)*(1-0.12*17/32);

            // Secteur AirTransport: -79% de la consommation de transport aérien
            Proj_Vol.C.val(19,:) = Proj_Vol.C.val(19,:)*(1-0.79*17/32);

            // Agriculture: -3% de la production agricole du à la réduction du gaspillage alimentaire
            Proj_Vol.C.val(20,:) = Proj_Vol.C.val(20,:)*(1-0.03*17/32);

            //////  CHOC CONSTRUCTION ////////
            // Construction: -51% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21,:) = Proj_Vol.C.val(21,:)*(1-0.51*17/32);

        end
    end
end
        

if time_step==3
    if Scenario=="AMSrun3mixnote" | Scenario=="AMSrun3mixnotebis" | Scenario=="AMS2026mesures_h10"
        if with_sufficiency_behaviour=="Sufficiency Choc S1"

            ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -72% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -3% dans le logement
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22*(1-0.03*22/32) + Proj_Vol.C.val(2,:)*0.78*(1-0.72*22/32);

            // Gas consumption: -3% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3,:) = Proj_Vol.C.val(3,:)*(1-0.03*22/32);

            // Coal consumption: -3% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4,:) = Proj_Vol.C.val(4,:)*(1-0.03*22/32);

            // Electricity consumption: -3% de la consommation du logement (83% de la consommation électricité issue du logement) + -72% de la consommation du transport (17% de la consommation d'electricité pour le transport)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*0.83*(1-0.03*22/32) + Proj_Vol.C.val(5,:)*0.17*(1-0.72*22/32);

            ///// CHOC VEHICULES NEUFS ////////
            // Secteur automobile: -54% d’achats de véhicules neufs 
            Proj_Vol.C.val(12,:) = Proj_Vol.C.val(12,:)*(1-0.54*22/32);

            ///// CHOC BIENS MANUFACTURES ////////
            // Secteur OthEq: -10% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13,:) = Proj_Vol.C.val(13,:)*(1-0.1*22/32);

            // Secteur Electroménager: -66% de consommation électroménager
            Proj_Vol.C.val(14,:) = Proj_Vol.C.val(14,:)*(1-0.66*22/32);
            
            ///// CHOC ALIMENTATION /////
            // Alimentation: -11% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15,:) = Proj_Vol.C.val(15,:)*(1-0.11*22/32);

            // Secteur OtherManufacturedGoods: -9% de consommation de vêtements, autres biens manufacturés,...
            Proj_Vol.C.val(16,:) = Proj_Vol.C.val(16,:)*(1-0.09*22/32);

            ///// CHOC TRANSPORT /////
            // Secteur LandTransport: -12% des déplacements en bus et train
            Proj_Vol.C.val(17,:) = Proj_Vol.C.val(17,:)*(1-0.12*22/32);

            // Secteur AirTransport: -79% de la consommation de transport aérien
            Proj_Vol.C.val(19,:) = Proj_Vol.C.val(19,:)*(1-0.79*22/32);

            // Agriculture: -3% de la production agricole du à la réduction du gaspillage alimentaire
            Proj_Vol.C.val(20,:) = Proj_Vol.C.val(20,:)*(1-0.03*22/32);

            //////  CHOC CONSTRUCTION ////////
            // Construction: -51% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21,:) = Proj_Vol.C.val(21,:)*(1-0.51*22/32);

        end
    end
end

if time_step==4
    if Scenario=="AMSrun3mixnote" | Scenario=="AMSrun3mixnotebis" | Scenario=="AMS2026mesures_h10"
        if with_sufficiency_behaviour=="Construction"
            ////// 1 - Choc Construction durable et Zéro artificialisation nette ////////
            // Construction: -50% de la construction neuve avec la zero artificialisation des sols
            // Proj_Vol.C.val(21) = Proj_Vol.C.val(21)*0.5;
            Proj_Vol.C.val(21,:) = Proj_Vol.C.val(21,:)*0.9;        
        
        elseif with_sufficiency_behaviour=="Sufficiency Choc S1"

             ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -72% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -3% dans le logement
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22*(1-0.03*32/32) + Proj_Vol.C.val(2,:)*0.78*(1-0.72*32/32);

            // Gas consumption: -3% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3,:) = Proj_Vol.C.val(3,:)*(1-0.03*32/32);

            // Coal consumption: -3% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4,:) = Proj_Vol.C.val(4,:)*(1-0.03*32/32);

            // Electricity consumption: -3% de la consommation du logement (75% de la consommation électricité issue du logement) + -72% de la consommation du transport (25% de la consommation d'electricité pour le transport)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*0.75*(1-0.03*32/32) + Proj_Vol.C.val(5,:)*0.25*(1-0.72*32/32);

            ///// CHOC VEHICULES NEUFS ////////
            // Secteur automobile: -54% d’achats de véhicules neufs 
            Proj_Vol.C.val(12,:) = Proj_Vol.C.val(12,:)*(1-0.54*32/32);

            ///// CHOC BIENS MANUFACTURES ////////
            // Secteur OthEq: -10% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13,:) = Proj_Vol.C.val(13,:)*(1-0.1*32/32);

            // Secteur Electroménager: -66% de consommation électroménager
            Proj_Vol.C.val(14,:) = Proj_Vol.C.val(14,:)*(1-0.66*32/32);
            
            ///// CHOC ALIMENTATION /////
            // Alimentation: -11% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15,:) = Proj_Vol.C.val(15,:)*(1-0.11*32/32);

            // Secteur OtherManufacturedGoods: -9% de consommation de vêtements, autres biens manufacturés,...
            Proj_Vol.C.val(16,:) = Proj_Vol.C.val(16,:)*(1-0.09*32/32);

            ///// CHOC TRANSPORT /////
            // Secteur LandTransport: -12% des déplacements en bus et train
            Proj_Vol.C.val(17,:) = Proj_Vol.C.val(17,:)*(1-0.12*32/32);

            // Secteur AirTransport: -79% de la consommation de transport aérien
            Proj_Vol.C.val(19,:) = Proj_Vol.C.val(19,:)*(1-0.79*32/32);

            // Agriculture: -3% de la production agricole du à la réduction du gaspillage alimentaire
            Proj_Vol.C.val(20,:) = Proj_Vol.C.val(20,:)*(1-0.03*32/32);

            //////  CHOC CONSTRUCTION ////////
            // Construction: -51% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21,:) = Proj_Vol.C.val(21,:)*(1-0.51*32/32);

        

        elseif with_sufficiency_behaviour=="Sufficiency Choc S1 - version 0"

             ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -50% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -5% dans le logement
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22*(1-0.05*32/32) + Proj_Vol.C.val(2,:)*0.78*(1-0.5*32/32);

            // Gas consumption: -5% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3,:) = Proj_Vol.C.val(3,:)*(1-0.05*32/32);

            // Coal consumption: -5% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4,:) = Proj_Vol.C.val(4,:)*(1-0.05*32/32);

            // Electricity consumption: -5% de la consommation du logement (100% de la consommation électricité issue du logement)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*(1-0.05*32/32);

            ///// CHOC VEHICULES NEUFS ////////
            // Secteur automobile: -50% d’achats de véhicules neufs 
            Proj_Vol.C.val(12,:) = Proj_Vol.C.val(12,:)*(1-0.5*32/32);

            ///// CHOC BIENS MANUFACTURES ////////
            // Secteur OthEq: -20% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13,:) = Proj_Vol.C.val(13,:)*(1-0.2*32/32);

            // Secteur Electroménager: -20% de consommation électroménager
            Proj_Vol.C.val(14,:) = Proj_Vol.C.val(14,:)*(1-0.2*32/32);
            
            ///// CHOC ALIMENTATION /////
            // Alimentation: -20% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15,:) = Proj_Vol.C.val(15,:)*(1-0.2*32/32);

            // Secteur OtherManufacturedGoods: -20% de consommation de vêtements, autres biens manufacturés,...
            Proj_Vol.C.val(16,:) = Proj_Vol.C.val(16,:)*(1-0.2*32/32);

            // Agriculture: -20% de la production agricole du à la réduction du gaspillage alimentaire
            Proj_Vol.C.val(20,:) = Proj_Vol.C.val(20,:)*(1-0.2*32/32);

            //////  CHOC CONSTRUCTION ////////
            // Construction: -50% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21,:) = Proj_Vol.C.val(21,:)*(1-0.5*32/32);

        end
    end
end

if with_sufficiency_behaviour=="Sufficiency Choc S1 in 2030"
    if Scenario=="AMSrun3mixnote" | Scenario=="AMSrun3mixnotebis" | Scenario=="AMS2026mesures_h10"
        if time_step==1|time_step==2|time_step==3|time_step==4
             ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -72% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -3% dans le logement
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22*(1-0.03*32/32) + Proj_Vol.C.val(2,:)*0.78*(1-0.72*32/32);

            // Gas consumption: -3% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3,:) = Proj_Vol.C.val(3,:)*(1-0.03*32/32);

            // Coal consumption: -3% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4,:) = Proj_Vol.C.val(4,:)*(1-0.03*32/32);

            // Electricity consumption: -3% de la consommation du logement (75% de la consommation électricité issue du logement) + -72% de la consommation du transport (25% de la consommation d'electricité pour le transport)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*0.75*(1-0.03*32/32) + Proj_Vol.C.val(5,:)*0.25*(1-0.72*32/32);

            ///// CHOC VEHICULES NEUFS ////////
            // Secteur automobile: -54% d’achats de véhicules neufs 
            Proj_Vol.C.val(12,:) = Proj_Vol.C.val(12,:)*(1-0.54*32/32);

            ///// CHOC BIENS MANUFACTURES ////////
            // Secteur OthEq: -10% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13,:) = Proj_Vol.C.val(13,:)*(1-0.1*32/32);

            // Secteur Electroménager: -66% de consommation électroménager
            Proj_Vol.C.val(14,:) = Proj_Vol.C.val(14,:)*(1-0.66*32/32);
            
            ///// CHOC ALIMENTATION /////
            // Alimentation: -11% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15,:) = Proj_Vol.C.val(15,:)*(1-0.11*32/32);

            // Secteur OtherManufacturedGoods: -9% de consommation de vêtements, autres biens manufacturés,...
            Proj_Vol.C.val(16,:) = Proj_Vol.C.val(16,:)*(1-0.09*32/32);

            ///// CHOC TRANSPORT /////
            // Secteur LandTransport: -12% des déplacements en bus et train
            Proj_Vol.C.val(17,:) = Proj_Vol.C.val(17,:)*(1-0.12*32/32);

            // Secteur AirTransport: -79% de la consommation de transport aérien
            Proj_Vol.C.val(19,:) = Proj_Vol.C.val(19,:)*(1-0.79*32/32);

            // Agriculture: -3% de la production agricole du à la réduction du gaspillage alimentaire
            Proj_Vol.C.val(20,:) = Proj_Vol.C.val(20,:)*(1-0.03*32/32);

            //////  CHOC CONSTRUCTION ////////
            // Construction: -51% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21,:) = Proj_Vol.C.val(21,:)*(1-0.51*32/32);
        end
    end
end


if with_sufficiency_behaviour=="Homogenous Choc S1"
    if Scenario=="AMSrun3mixnote" | Scenario=="AMSrun3mixnotebis" | Scenario=="AMS2026mesures_h10"
        if time_step==1
            // In this scenario, we apply a uniform reduction across all sectors by 7.712% to simulate a homogenous shock. 7.712 corresponds to the reduction of demand C of S1 with the price of 2018
            Proj_Vol.C.val(:,:) = Proj_Vol.C.val(:,:)*(1-0.09657)
        
        elseif time_step==2
            // In this scenario, we apply a uniform reduction across all sectors by 7.712% to simulate a homogenous shock. 7.712 corresponds to the reduction of demand C of S1 with the price of 2018
            Proj_Vol.C.val(:,:) = Proj_Vol.C.val(:,:)*(1-0.09233)

        elseif time_step==3
            // In this scenario, we apply a uniform reduction across all sectors by 7.712% to simulate a homogenous shock. 7.712 corresponds to the reduction of demand C of S1 with the price of 2018
            Proj_Vol.C.val(:,:) = Proj_Vol.C.val(:,:)*(1-0.08834)

        elseif time_step==4
            // In this scenario, we apply a uniform reduction across all sectors by 7.712% to simulate a homogenous shock. 7.712 corresponds to the reduction of demand C of S1 with the price of 2018
            Proj_Vol.C.val(:,:) = Proj_Vol.C.val(:,:)*(1-0.07712)
        end
    end
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////// Cas d'un choc S1 cumulé  //////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

if Scenario=="AMSrun3mixnote" | Scenario=="AMSrun3mixnotebis" | Scenario=="AMS2026mesures_h10"
    if time_step==1|time_step==2|time_step==3|time_step==4
        if with_sufficiency_behaviour=="Deplacements"
             ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -72% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports)
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22 + Proj_Vol.C.val(2,:)*0.78*(1-0.72*32/32);

            // Electricity consumption: -72% de la consommation du transport (25% de la consommation d'electricité pour le transport)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*0.75 + Proj_Vol.C.val(5,:)*0.25*(1-0.72*32/32);


        elseif with_sufficiency_behaviour=="Deplacements X Chauffage"
             ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -72% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -3% dans le logement
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22*(1-0.03*32/32) + Proj_Vol.C.val(2,:)*0.78*(1-0.72*32/32);

            // Gas consumption: -3% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3,:) = Proj_Vol.C.val(3,:)*(1-0.03*32/32);

            // Coal consumption: -3% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4,:) = Proj_Vol.C.val(4,:)*(1-0.03*32/32);

            // Electricity consumption: -3% de la consommation du logement (75% de la consommation électricité issue du logement) + -72% de la consommation du transport (25% de la consommation d'electricité pour le transport)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*0.75*(1-0.03*32/32) + Proj_Vol.C.val(5,:)*0.25*(1-0.72*32/32);

        
        elseif with_sufficiency_behaviour=="Deplacements X Chauffage X Auto"

             ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -72% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -3% dans le logement
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22*(1-0.03*32/32) + Proj_Vol.C.val(2,:)*0.78*(1-0.72*32/32);

            // Gas consumption: -3% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3,:) = Proj_Vol.C.val(3,:)*(1-0.03*32/32);

            // Coal consumption: -3% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4,:) = Proj_Vol.C.val(4,:)*(1-0.03*32/32);

            // Electricity consumption: -3% de la consommation du logement (75% de la consommation électricité issue du logement) + -72% de la consommation du transport (25% de la consommation d'electricité pour le transport)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*0.75*(1-0.03*32/32) + Proj_Vol.C.val(5,:)*0.25*(1-0.72*32/32);

            ///// CHOC VEHICULES NEUFS ////////
            // Secteur automobile: -54% d’achats de véhicules neufs 
            Proj_Vol.C.val(12,:) = Proj_Vol.C.val(12,:)*(1-0.54*32/32);

        
        elseif with_sufficiency_behaviour=="Deplacements X Chauffage X Auto X OthEq"

             ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -72% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -3% dans le logement
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22*(1-0.03*32/32) + Proj_Vol.C.val(2,:)*0.78*(1-0.72*32/32);

            // Gas consumption: -3% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3,:) = Proj_Vol.C.val(3,:)*(1-0.03*32/32);

            // Coal consumption: -3% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4,:) = Proj_Vol.C.val(4,:)*(1-0.03*32/32);

            // Electricity consumption: -3% de la consommation du logement (75% de la consommation électricité issue du logement) + -72% de la consommation du transport (25% de la consommation d'electricité pour le transport)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*0.75*(1-0.03*32/32) + Proj_Vol.C.val(5,:)*0.25*(1-0.72*32/32);

            ///// CHOC VEHICULES NEUFS ////////
            // Secteur automobile: -54% d’achats de véhicules neufs 
            Proj_Vol.C.val(12,:) = Proj_Vol.C.val(12,:)*(1-0.54*32/32);

            ///// CHOC BIENS MANUFACTURES ////////
            // Secteur OthEq: -10% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13,:) = Proj_Vol.C.val(13,:)*(1-0.1*32/32);

        
        elseif with_sufficiency_behaviour=="Deplacements X Chauffage X Auto X OthEq X Electromenager"

             ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -72% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -3% dans le logement
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22*(1-0.03*32/32) + Proj_Vol.C.val(2,:)*0.78*(1-0.72*32/32);

            // Gas consumption: -3% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3,:) = Proj_Vol.C.val(3,:)*(1-0.03*32/32);

            // Coal consumption: -3% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4,:) = Proj_Vol.C.val(4,:)*(1-0.03*32/32);

            // Electricity consumption: -3% de la consommation du logement (75% de la consommation électricité issue du logement) + -72% de la consommation du transport (25% de la consommation d'electricité pour le transport)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*0.75*(1-0.03*32/32) + Proj_Vol.C.val(5,:)*0.25*(1-0.72*32/32);

            ///// CHOC VEHICULES NEUFS ////////
            // Secteur automobile: -54% d’achats de véhicules neufs 
            Proj_Vol.C.val(12,:) = Proj_Vol.C.val(12,:)*(1-0.54*32/32);

            ///// CHOC BIENS MANUFACTURES ////////
            // Secteur OthEq: -10% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13,:) = Proj_Vol.C.val(13,:)*(1-0.1*32/32);

            // Secteur Electroménager: -66% de consommation électroménager
            Proj_Vol.C.val(14,:) = Proj_Vol.C.val(14,:)*(1-0.66*32/32);
            
        

        elseif with_sufficiency_behaviour=="Deplacements X Chauffage X Auto X OthEq X Electromenager X Food"

             ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -72% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -3% dans le logement
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22*(1-0.03*32/32) + Proj_Vol.C.val(2,:)*0.78*(1-0.72*32/32);

            // Gas consumption: -3% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3,:) = Proj_Vol.C.val(3,:)*(1-0.03*32/32);

            // Coal consumption: -3% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4,:) = Proj_Vol.C.val(4,:)*(1-0.03*32/32);

            // Electricity consumption: -3% de la consommation du logement (75% de la consommation électricité issue du logement) + -72% de la consommation du transport (25% de la consommation d'electricité pour le transport)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*0.75*(1-0.03*32/32) + Proj_Vol.C.val(5,:)*0.25*(1-0.72*32/32);

            ///// CHOC VEHICULES NEUFS ////////
            // Secteur automobile: -54% d’achats de véhicules neufs 
            Proj_Vol.C.val(12,:) = Proj_Vol.C.val(12,:)*(1-0.54*32/32);

            ///// CHOC BIENS MANUFACTURES ////////
            // Secteur OthEq: -10% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13,:) = Proj_Vol.C.val(13,:)*(1-0.1*32/32);

            // Secteur Electroménager: -66% de consommation électroménager
            Proj_Vol.C.val(14,:) = Proj_Vol.C.val(14,:)*(1-0.66*32/32);
            
            ///// CHOC ALIMENTATION /////
            // Alimentation: -11% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15,:) = Proj_Vol.C.val(15,:)*(1-0.11*32/32);

        
        elseif with_sufficiency_behaviour=="Deplacements X Chauffage X Auto X OthEq X Electromenager X Food X OtherManuf"

             ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -72% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -3% dans le logement
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22*(1-0.03*32/32) + Proj_Vol.C.val(2,:)*0.78*(1-0.72*32/32);

            // Gas consumption: -3% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3,:) = Proj_Vol.C.val(3,:)*(1-0.03*32/32);

            // Coal consumption: -3% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4,:) = Proj_Vol.C.val(4,:)*(1-0.03*32/32);

            // Electricity consumption: -3% de la consommation du logement (75% de la consommation électricité issue du logement) + -72% de la consommation du transport (25% de la consommation d'electricité pour le transport)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*0.75*(1-0.03*32/32) + Proj_Vol.C.val(5,:)*0.25*(1-0.72*32/32);

            ///// CHOC VEHICULES NEUFS ////////
            // Secteur automobile: -54% d’achats de véhicules neufs 
            Proj_Vol.C.val(12,:) = Proj_Vol.C.val(12,:)*(1-0.54*32/32);

            ///// CHOC BIENS MANUFACTURES ////////
            // Secteur OthEq: -10% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13,:) = Proj_Vol.C.val(13,:)*(1-0.1*32/32);

            // Secteur Electroménager: -66% de consommation électroménager
            Proj_Vol.C.val(14,:) = Proj_Vol.C.val(14,:)*(1-0.66*32/32);
            
            ///// CHOC ALIMENTATION /////
            // Alimentation: -11% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15,:) = Proj_Vol.C.val(15,:)*(1-0.11*32/32);

            // Secteur OtherManufacturedGoods: -9% de consommation de vêtements, autres biens manufacturés,...
            Proj_Vol.C.val(16,:) = Proj_Vol.C.val(16,:)*(1-0.09*32/32);
        
        
        elseif with_sufficiency_behaviour=="Deplacements X Chauffage X Auto X OthEq X Electromenager X Food X OtherManuf X LandTransp"

             ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -72% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -3% dans le logement
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22*(1-0.03*32/32) + Proj_Vol.C.val(2,:)*0.78*(1-0.72*32/32);

            // Gas consumption: -3% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3,:) = Proj_Vol.C.val(3,:)*(1-0.03*32/32);

            // Coal consumption: -3% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4,:) = Proj_Vol.C.val(4,:)*(1-0.03*32/32);

            // Electricity consumption: -3% de la consommation du logement (75% de la consommation électricité issue du logement) + -72% de la consommation du transport (25% de la consommation d'electricité pour le transport)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*0.75*(1-0.03*32/32) + Proj_Vol.C.val(5,:)*0.25*(1-0.72*32/32);

            ///// CHOC VEHICULES NEUFS ////////
            // Secteur automobile: -54% d’achats de véhicules neufs 
            Proj_Vol.C.val(12,:) = Proj_Vol.C.val(12,:)*(1-0.54*32/32);

            ///// CHOC BIENS MANUFACTURES ////////
            // Secteur OthEq: -10% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13,:) = Proj_Vol.C.val(13,:)*(1-0.1*32/32);

            // Secteur Electroménager: -66% de consommation électroménager
            Proj_Vol.C.val(14,:) = Proj_Vol.C.val(14,:)*(1-0.66*32/32);
            
            ///// CHOC ALIMENTATION /////
            // Alimentation: -11% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15,:) = Proj_Vol.C.val(15,:)*(1-0.11*32/32);

            // Secteur OtherManufacturedGoods: -9% de consommation de vêtements, autres biens manufacturés,...
            Proj_Vol.C.val(16,:) = Proj_Vol.C.val(16,:)*(1-0.09*32/32);

            ///// CHOC TRANSPORT /////
            // Secteur LandTransport: -12% des déplacements en bus et train
            Proj_Vol.C.val(17,:) = Proj_Vol.C.val(17,:)*(1-0.12*32/32);
        

        elseif with_sufficiency_behaviour=="Deplacements X Chauffage X Auto X OthEq X Electromenager X Food X OtherManuf X LandTransp X AirTransp"

             ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -72% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -3% dans le logement
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22*(1-0.03*32/32) + Proj_Vol.C.val(2,:)*0.78*(1-0.72*32/32);

            // Gas consumption: -3% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3,:) = Proj_Vol.C.val(3,:)*(1-0.03*32/32);

            // Coal consumption: -3% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4,:) = Proj_Vol.C.val(4,:)*(1-0.03*32/32);

            // Electricity consumption: -3% de la consommation du logement (75% de la consommation électricité issue du logement) + -72% de la consommation du transport (25% de la consommation d'electricité pour le transport)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*0.75*(1-0.03*32/32) + Proj_Vol.C.val(5,:)*0.25*(1-0.72*32/32);

            ///// CHOC VEHICULES NEUFS ////////
            // Secteur automobile: -54% d’achats de véhicules neufs 
            Proj_Vol.C.val(12,:) = Proj_Vol.C.val(12,:)*(1-0.54*32/32);

            ///// CHOC BIENS MANUFACTURES ////////
            // Secteur OthEq: -10% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13,:) = Proj_Vol.C.val(13,:)*(1-0.1*32/32);

            // Secteur Electroménager: -66% de consommation électroménager
            Proj_Vol.C.val(14,:) = Proj_Vol.C.val(14,:)*(1-0.66*32/32);
            
            ///// CHOC ALIMENTATION /////
            // Alimentation: -11% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15,:) = Proj_Vol.C.val(15,:)*(1-0.11*32/32);

            // Secteur OtherManufacturedGoods: -9% de consommation de vêtements, autres biens manufacturés,...
            Proj_Vol.C.val(16,:) = Proj_Vol.C.val(16,:)*(1-0.09*32/32);

            ///// CHOC TRANSPORT /////
            // Secteur LandTransport: -12% des déplacements en bus et train
            Proj_Vol.C.val(17,:) = Proj_Vol.C.val(17,:)*(1-0.12*32/32);

            // Secteur AirTransport: -79% de la consommation de transport aérien
            Proj_Vol.C.val(19,:) = Proj_Vol.C.val(19,:)*(1-0.79*32/32);

        
        elseif with_sufficiency_behaviour=="Deplacements X Chauffage X Auto X OthEq X Electromenager X Food X OtherManuf X LandTransp X AirTransp X Agri"

             ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -72% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -3% dans le logement
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22*(1-0.03*32/32) + Proj_Vol.C.val(2,:)*0.78*(1-0.72*32/32);

            // Gas consumption: -3% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3,:) = Proj_Vol.C.val(3,:)*(1-0.03*32/32);

            // Coal consumption: -3% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4,:) = Proj_Vol.C.val(4,:)*(1-0.03*32/32);

            // Electricity consumption: -3% de la consommation du logement (75% de la consommation électricité issue du logement) + -72% de la consommation du transport (25% de la consommation d'electricité pour le transport)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*0.75*(1-0.03*32/32) + Proj_Vol.C.val(5,:)*0.25*(1-0.72*32/32);

            ///// CHOC VEHICULES NEUFS ////////
            // Secteur automobile: -54% d’achats de véhicules neufs 
            Proj_Vol.C.val(12,:) = Proj_Vol.C.val(12,:)*(1-0.54*32/32);

            ///// CHOC BIENS MANUFACTURES ////////
            // Secteur OthEq: -10% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13,:) = Proj_Vol.C.val(13,:)*(1-0.1*32/32);

            // Secteur Electroménager: -66% de consommation électroménager
            Proj_Vol.C.val(14,:) = Proj_Vol.C.val(14,:)*(1-0.66*32/32);
            
            ///// CHOC ALIMENTATION /////
            // Alimentation: -11% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15,:) = Proj_Vol.C.val(15,:)*(1-0.11*32/32);

            // Secteur OtherManufacturedGoods: -9% de consommation de vêtements, autres biens manufacturés,...
            Proj_Vol.C.val(16,:) = Proj_Vol.C.val(16,:)*(1-0.09*32/32);

            ///// CHOC TRANSPORT /////
            // Secteur LandTransport: -12% des déplacements en bus et train
            Proj_Vol.C.val(17,:) = Proj_Vol.C.val(17,:)*(1-0.12*32/32);

            // Secteur AirTransport: -79% de la consommation de transport aérien
            Proj_Vol.C.val(19,:) = Proj_Vol.C.val(19,:)*(1-0.79*32/32);

            // Agriculture: -3% de la production agricole du à la réduction du gaspillage alimentaire
            Proj_Vol.C.val(20,:) = Proj_Vol.C.val(20,:)*(1-0.03*32/32);


        elseif with_sufficiency_behaviour=="Deplacements X Chauffage X Auto X OthEq X Electromenager X Food X OtherManuf X LandTransp X AirTransp X Agri X Construction"

             ///// CHOCS ENERGETIQUES ////////
            // Oil consumption: -72% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -3% dans le logement
            Proj_Vol.C.val(2,:) = Proj_Vol.C.val(2,:)*0.22*(1-0.03*32/32) + Proj_Vol.C.val(2,:)*0.78*(1-0.72*32/32);

            // Gas consumption: -3% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3,:) = Proj_Vol.C.val(3,:)*(1-0.03*32/32);

            // Coal consumption: -3% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4,:) = Proj_Vol.C.val(4,:)*(1-0.03*32/32);

            // Electricity consumption: -3% de la consommation du logement (75% de la consommation électricité issue du logement) + -72% de la consommation du transport (25% de la consommation d'electricité pour le transport)
            Proj_Vol.C.val(5,:) = Proj_Vol.C.val(5,:)*0.75*(1-0.03*32/32) + Proj_Vol.C.val(5,:)*0.25*(1-0.72*32/32);

            ///// CHOC VEHICULES NEUFS ////////
            // Secteur automobile: -54% d’achats de véhicules neufs 
            Proj_Vol.C.val(12,:) = Proj_Vol.C.val(12,:)*(1-0.54*32/32);

            ///// CHOC BIENS MANUFACTURES ////////
            // Secteur OthEq: -10% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13,:) = Proj_Vol.C.val(13,:)*(1-0.1*32/32);

            // Secteur Electroménager: -66% de consommation électroménager
            Proj_Vol.C.val(14,:) = Proj_Vol.C.val(14,:)*(1-0.66*32/32);
            
            ///// CHOC ALIMENTATION /////
            // Alimentation: -11% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15,:) = Proj_Vol.C.val(15,:)*(1-0.11*32/32);

            // Secteur OtherManufacturedGoods: -9% de consommation de vêtements, autres biens manufacturés,...
            Proj_Vol.C.val(16,:) = Proj_Vol.C.val(16,:)*(1-0.09*32/32);

            ///// CHOC TRANSPORT /////
            // Secteur LandTransport: -12% des déplacements en bus et train
            Proj_Vol.C.val(17,:) = Proj_Vol.C.val(17,:)*(1-0.12*32/32);

            // Secteur AirTransport: -79% de la consommation de transport aérien
            Proj_Vol.C.val(19,:) = Proj_Vol.C.val(19,:)*(1-0.79*32/32);

            // Agriculture: -3% de la production agricole du à la réduction du gaspillage alimentaire
            Proj_Vol.C.val(20,:) = Proj_Vol.C.val(20,:)*(1-0.03*32/32);

            //////  CHOC CONSTRUCTION ////////
            // Construction: -51% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21,:) = Proj_Vol.C.val(21,:)*(1-0.51*32/32);
        end
    end
end