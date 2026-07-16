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

if  VAR_saving=="ref"
    if time_step==1 then
        Deriv_Exogenous.Household_saving_rate = 0.1632678;
    elseif time_step==2 then
        Deriv_Exogenous.Household_saving_rate = 0.1962235;
    elseif time_step==3 then
        Deriv_Exogenous.Household_saving_rate = 0.2187141;
    end
end

if  VAR_saving=="moderate"
    if time_step==1 then
        Deriv_Exogenous.Household_saving_rate = 0.1739711;
    elseif time_step==2 then
        Deriv_Exogenous.Household_saving_rate = 0.2138841;
    elseif time_step==3 then
        Deriv_Exogenous.Household_saving_rate = 0.2409163;
    end
end

if  VAR_saving=="with_full_sufficiency"
    if time_step==1 then
        Deriv_Exogenous.Household_saving_rate = 0.1846744;
    elseif time_step==2 then
        Deriv_Exogenous.Household_saving_rate = 0.2315447;
    elseif time_step==3 then
        Deriv_Exogenous.Household_saving_rate = 0.2631185;
    end
end

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
    if Scenario=="AMSrun3mixnote" | Scenario=="AMSrun3mixnotebis"
        if with_sufficiency_behaviour=="Construction X Chauffage X Gaspillage alimentaire X Achat vehicules neufs X Deplacements X OthEq X Electromenager X OtherManufacturedGoods"

            ////// 1 - Choc Construction durable et Zéro artificialisation nette ////////
            // Construction: -50% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21) = Proj_Vol.C.val(21)*(1-0.5*12/32);

            ///// 2 - Choc consommation énergétique des ménages sur le logement ////////
            // Oil consumption: -5% de la consommation du logement (22 % consommation oil est issue des logements /78 % des transports)  
            // Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*0.95 + Proj_Vol.C.val(2)*0.78*1;

            // Gas consumption: -5% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3) = Proj_Vol.C.val(3)*(1-0.05*12/32);

            // Coal consumption: -5% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4) = Proj_Vol.C.val(4)*(1-0.05*12/32);

            // Electricity consumption: -5% de la consommation du logement (100% de la consommation électricité issue du logement)
            Proj_Vol.C.val(5) = Proj_Vol.C.val(5)*(1-0.05*12/32);


            ///// 3 - Choc Alimentation et Gaspillage alimentaire /////
            // Alimentation: -20% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15) = Proj_Vol.C.val(15)*(1-0.2*12/32);

            // Agriculture: -20% de la production agricole du à la réduction du gaspillage alimentaire
            Proj_Vol.C.val(20) = Proj_Vol.C.val(20)*(1-0.2*12/32);


            ///// 4 - Choc véhicules neufs////////
            // Secteur automobile: -50% d’achats de véhicules neufs 
            Proj_Vol.C.val(12) = Proj_Vol.C.val(12)*(1-0.5*12/32);

            ///// 5 - Choc consommation transport + chauffage logement ////////
            // Oil consumption: -50% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -5% dans le logement
            Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*(1-0.05*12/32) + Proj_Vol.C.val(2)*0.78*(1-0.5*12/32);


            ///// 6 - Choc consommation de biens manufacturés ////////
            // Secteur OthEq: -20% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13) = Proj_Vol.C.val(13)*(1-0.2*12/32);

            // Secteur Electroménager: -20% de consommation électroménager
            Proj_Vol.C.val(14) = Proj_Vol.C.val(14)*(1-0.2*12/32);

            // Secteur OtherManufacturedGoods: -20% de consommation de vêtements, autres biens manufacturés,...
            Proj_Vol.C.val(16) = Proj_Vol.C.val(16)*(1-0.2*12/32);
        end
    end
end

        

if time_step==2
    if Scenario=="AMSrun3mixnote" | Scenario=="AMSrun3mixnotebis"
        if with_sufficiency_behaviour=="Construction X Chauffage X Gaspillage alimentaire X Achat vehicules neufs X Deplacements X OthEq X Electromenager X OtherManufacturedGoods"

            ////// 1 - Choc Construction durable et Zéro artificialisation nette ////////
            // Construction: -50% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21) = Proj_Vol.C.val(21)*(1-0.5*22/32);

            ///// 2 - Choc consommation énergétique des ménages sur le logement ////////
            // Oil consumption: -5% de la consommation du logement (22 % consommation oil est issue des logements /78 % des transports)  
            // Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*0.95 + Proj_Vol.C.val(2)*0.78*1;

            // Gas consumption: -5% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3) = Proj_Vol.C.val(3)*(1-0.05*22/32);

            // Coal consumption: -5% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4) = Proj_Vol.C.val(4)*(1-0.05*22/32);

            // Electricity consumption: -5% de la consommation du logement (100% de la consommation électricité issue du logement)
            Proj_Vol.C.val(5) = Proj_Vol.C.val(5)*(1-0.05*22/32);


            ///// 3 - Choc Alimentation et Gaspillage alimentaire /////
            // Alimentation: -20% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15) = Proj_Vol.C.val(15)*(1-0.2*22/32);

            // Agriculture: -20% de la production agricole du à la réduction du gaspillage alimentaire
            Proj_Vol.C.val(20) = Proj_Vol.C.val(20)*(1-0.2*22/32);


            ///// 4 - Choc véhicules neufs////////
            // Secteur automobile: -50% d’achats de véhicules neufs 
            Proj_Vol.C.val(12) = Proj_Vol.C.val(12)*(1-0.5*22/32);

            ///// 5 - Choc consommation transport + chauffage logement ////////
            // Oil consumption: -50% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports) et -5% dans le logement
            Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*(1-0.05*22/32) + Proj_Vol.C.val(2)*0.78*(1-0.5*22/32);


            ///// 6 - Choc consommation de biens manufacturés ////////
            // Secteur OthEq: -20% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13) = Proj_Vol.C.val(13)*(1-0.2*22/32);

            // Secteur Electroménager: -20% de consommation électroménager
            Proj_Vol.C.val(14) = Proj_Vol.C.val(14)*(1-0.2*22/32);

            // Secteur OtherManufacturedGoods: -20% de consommation de vêtements, autres biens manufacturés,...
            Proj_Vol.C.val(16) = Proj_Vol.C.val(16)*(1-0.2*22/32);
        end
    end
end

if time_step==3
    if Scenario=="AMSrun3mixnote" | Scenario=="AMSrun3mixnotebis"
        if with_sufficiency_behaviour=="Construction"
            ////// 1 - Choc Construction durable et Zéro artificialisation nette ////////
            // Construction: -50% de la construction neuve avec la zero artificialisation des sols
            // Proj_Vol.C.val(21) = Proj_Vol.C.val(21)*0.5;
            Proj_Vol.C.val(21) = Proj_Vol.C.val(21)*0.9;


        elseif with_sufficiency_behaviour=="Chauffage"
            ///// 2 - Choc consommation énergétique des ménages sur le logement ////////
            // Oil consumption: -5% de la consommation du logement (22 % consommation oil est issue des logements /78 % des transports)  
            // Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*0.95 + Proj_Vol.C.val(2)*0.78*1;
            Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*0.9 + Proj_Vol.C.val(2)*0.78*1;

            // Gas consumption: -5% de la consommation du logement (100 % consommation gaz issue du logement)
            // Proj_Vol.C.val(3) = Proj_Vol.C.val(3)*0.95;
            Proj_Vol.C.val(3) = Proj_Vol.C.val(3)*0.9;

            // Coal consumption: -5% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            // Proj_Vol.C.val(4) = Proj_Vol.C.val(4)*0.95;
            Proj_Vol.C.val(4) = Proj_Vol.C.val(4)*0.9;

            // Electricity consumption: -5% de la consommation du logement (100% de la consommation électricité issue du logement)
            // Proj_Vol.C.val(5) = Proj_Vol.C.val(5)*0.95;
            Proj_Vol.C.val(5) = Proj_Vol.C.val(5)*0.9;



        elseif with_sufficiency_behaviour=="Gaspillage alimentaire"
            ///// 3 - Choc Alimentation et Gaspillage alimentaire /////
            // Alimentation: -20% car on réduit fortement le gaspillage alimentaire
            // Proj_Vol.C.val(15) = Proj_Vol.C.val(15)*0.8;
            Proj_Vol.C.val(15) = Proj_Vol.C.val(15)*0.95;

            // Agriculture: -20% de la production agricole du à la réduction du gaspillage alimentaire
            // Proj_Vol.C.val(20) = Proj_Vol.C.val(20)*0.8;
            Proj_Vol.C.val(20) = Proj_Vol.C.val(20)*0.95;


        elseif with_sufficiency_behaviour=="Achat vehicules neufs"
            ///// 4 - Choc consommation énergétique des ménages sur les transports ////////
            // Secteur automobile: -50% d’achats de véhicules neufs 
            // Proj_Vol.C.val(12) = Proj_Vol.C.val(12)*0.5;
            Proj_Vol.C.val(12) = Proj_Vol.C.val(12)*0.9;

        elseif with_sufficiency_behaviour=="Deplacements"
            // Oil consumption: -50% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports)  
            // Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*1 + Proj_Vol.C.val(2)*0.78*0.5;
            Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*1 + Proj_Vol.C.val(2)*0.78*0.9;

        elseif with_sufficiency_behaviour=="OthEq"
            ///// 5 - Choc consommation de biens manufacturés ////////
            // Secteur OthEq: -20% de consommation TV, ordi, smartphone
            // Proj_Vol.C.val(13) = Proj_Vol.C.val(13)*0.8;
            Proj_Vol.C.val(13) = Proj_Vol.C.val(13)*0.9;

        elseif with_sufficiency_behaviour=="Electromenager"
            //Secteur Electroménager: -20% de consommation électroménager
            // Proj_Vol.C.val(14) = Proj_Vol.C.val(14)*0.8;
            Proj_Vol.C.val(14) = Proj_Vol.C.val(14)*0.9;

        elseif with_sufficiency_behaviour=="OtherManufacturedGoods"
            // Secteur OtherManufacturedGoods: -20% de consommation de vêtements, autres biens manufacturés,...
            // Proj_Vol.C.val(16) = Proj_Vol.C.val(16)*0.8;
            Proj_Vol.C.val(16) = Proj_Vol.C.val(16)*0.9;

        elseif with_sufficiency_behaviour=="False"
            // les valeurs de références pour tous les secteurs ci-dessus
            Proj_Vol.C.val(2) = Proj_Vol.C.val(2);
            Proj_Vol.C.val(3) = Proj_Vol.C.val(3);
            Proj_Vol.C.val(4) = Proj_Vol.C.val(4);
            Proj_Vol.C.val(5) = Proj_Vol.C.val(5);
            Proj_Vol.C.val(12) = Proj_Vol.C.val(12);
            Proj_Vol.C.val(13) = Proj_Vol.C.val(13);
            Proj_Vol.C.val(14) = Proj_Vol.C.val(14);
            Proj_Vol.C.val(15) = Proj_Vol.C.val(15);
            Proj_Vol.C.val(16) = Proj_Vol.C.val(16);
            Proj_Vol.C.val(20) = Proj_Vol.C.val(20);
            Proj_Vol.C.val(21) = Proj_Vol.C.val(21);
        

        elseif with_sufficiency_behaviour=="Construction"

            ////// 1 - Choc Construction durable et Zéro artificialisation nette ////////
            // Construction: -50% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21) = Proj_Vol.C.val(21)*0.5;


        elseif with_sufficiency_behaviour=="Construction X Chauffage"

            ////// 1 - Choc Construction durable et Zéro artificialisation nette ////////
            // Construction: -50% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21) = Proj_Vol.C.val(21)*0.5;

        
            ///// 2 - Choc consommation énergétique des ménages sur le logement ////////
            // Oil consumption: -5% de la consommation du logement (22 % consommation oil est issue des logements /78 % des transports)  
            Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*0.95 + Proj_Vol.C.val(2)*0.78*1;

            // Gas consumption: -5% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3) = Proj_Vol.C.val(3)*0.95;

            // Coal consumption: -5% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4) = Proj_Vol.C.val(4)*0.95;

            // Electricity consumption: -5% de la consommation du logement (100% de la consommation électricité issue du logement)
            Proj_Vol.C.val(5) = Proj_Vol.C.val(5)*0.95;

        
        elseif with_sufficiency_behaviour=="Construction X Chauffage X Gaspillage alimentaire"

            ////// 1 - Choc Construction durable et Zéro artificialisation nette ////////
            // Construction: -50% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21) = Proj_Vol.C.val(21)*0.5;

        
            ///// 2 - Choc consommation énergétique des ménages sur le logement ////////
            // Oil consumption: -5% de la consommation du logement (22 % consommation oil est issue des logements /78 % des transports)  
            Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*0.95 + Proj_Vol.C.val(2)*0.78*1;

            // Gas consumption: -5% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3) = Proj_Vol.C.val(3)*0.95;

            // Coal consumption: -5% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4) = Proj_Vol.C.val(4)*0.95;

            // Electricity consumption: -5% de la consommation du logement (100% de la consommation électricité issue du logement)
            Proj_Vol.C.val(5) = Proj_Vol.C.val(5)*0.95;


            ///// 3 - Choc Alimentation et Gaspillage alimentaire /////
            // Alimentation: -20% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15) = Proj_Vol.C.val(15)*0.8;

            // Agriculture: -20% de la production agricole du à la réduction du gaspillage alimentaire
            Proj_Vol.C.val(20) = Proj_Vol.C.val(20)*0.8;

        
        elseif with_sufficiency_behaviour=="Construction X Chauffage X Gaspillage alimentaire X Achat vehicules neufs"

            ////// 1 - Choc Construction durable et Zéro artificialisation nette ////////
            // Construction: -50% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21) = Proj_Vol.C.val(21)*0.5;

        
            ///// 2 - Choc consommation énergétique des ménages sur le logement ////////
            // Oil consumption: -5% de la consommation du logement (22 % consommation oil est issue des logements /78 % des transports)  
            Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*0.95 + Proj_Vol.C.val(2)*0.78*1;

            // Gas consumption: -5% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3) = Proj_Vol.C.val(3)*0.95;

            // Coal consumption: -5% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4) = Proj_Vol.C.val(4)*0.95;

            // Electricity consumption: -5% de la consommation du logement (100% de la consommation électricité issue du logement)
            Proj_Vol.C.val(5) = Proj_Vol.C.val(5)*0.95;


            ///// 3 - Choc Alimentation et Gaspillage alimentaire /////
            // Alimentation: -20% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15) = Proj_Vol.C.val(15)*0.8;

            // Agriculture: -20% de la production agricole du à la réduction du gaspillage alimentaire
            Proj_Vol.C.val(20) = Proj_Vol.C.val(20)*0.8;


            ///// 4 - Choc véchiules neufs ////////
            // Secteur automobile: -50% d’achats de véhicules neufs 
            Proj_Vol.C.val(12) = Proj_Vol.C.val(12)*0.5;

        
        elseif with_sufficiency_behaviour=="Construction X Chauffage X Gaspillage alimentaire X Achat vehicules neufs X Deplacements"

            ////// 1 - Choc Construction durable et Zéro artificialisation nette ////////
            // Construction: -50% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21) = Proj_Vol.C.val(21)*0.5;

        
            ///// 2 - Choc consommation énergétique des ménages sur le logement ////////
            // Oil consumption: -5% de la consommation du logement (22 % consommation oil est issue des logements /78 % des transports)  
            // Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*0.95 + Proj_Vol.C.val(2)*0.78*1;

            // Gas consumption: -5% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3) = Proj_Vol.C.val(3)*0.95;

            // Coal consumption: -5% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4) = Proj_Vol.C.val(4)*0.95;

            // Electricity consumption: -5% de la consommation du logement (100% de la consommation électricité issue du logement)
            Proj_Vol.C.val(5) = Proj_Vol.C.val(5)*0.95;


            ///// 3 - Choc Alimentation et Gaspillage alimentaire /////
            // Alimentation: -20% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15) = Proj_Vol.C.val(15)*0.8;

            // Agriculture: -20% de la production agricole du à la réduction du gaspillage alimentaire
            Proj_Vol.C.val(20) = Proj_Vol.C.val(20)*0.8;


            ///// 4 - Choc véhicules neufs////////
            // Secteur automobile: -50% d’achats de véhicules neufs 
            Proj_Vol.C.val(12) = Proj_Vol.C.val(12)*0.5;

            ///// 5 - Choc consommation transport + chauffage logement ////////
            // Oil consumption: -50% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports)  
            Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*0.95 + Proj_Vol.C.val(2)*0.78*0.5;


        elseif with_sufficiency_behaviour=="Construction X Chauffage X Gaspillage alimentaire X Achat vehicules neufs X Deplacements X OthEq"
            
            ////// 1 - Choc Construction durable et Zéro artificialisation nette ////////
            // Construction: -50% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21) = Proj_Vol.C.val(21)*0.5;

        
            ///// 2 - Choc consommation énergétique des ménages sur le logement ////////
            // Oil consumption: -5% de la consommation du logement (22 % consommation oil est issue des logements /78 % des transports)  
            // Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*0.95 + Proj_Vol.C.val(2)*0.78*1;

            // Gas consumption: -5% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3) = Proj_Vol.C.val(3)*0.95;

            // Coal consumption: -5% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4) = Proj_Vol.C.val(4)*0.95;

            // Electricity consumption: -5% de la consommation du logement (100% de la consommation électricité issue du logement)
            Proj_Vol.C.val(5) = Proj_Vol.C.val(5)*0.95;


            ///// 3 - Choc Alimentation et Gaspillage alimentaire /////
            // Alimentation: -20% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15) = Proj_Vol.C.val(15)*0.8;

            // Agriculture: -20% de la production agricole du à la réduction du gaspillage alimentaire
            Proj_Vol.C.val(20) = Proj_Vol.C.val(20)*0.8;


            ///// 4 - Choc véhicules neufs////////
            // Secteur automobile: -50% d’achats de véhicules neufs 
            Proj_Vol.C.val(12) = Proj_Vol.C.val(12)*0.5;

            ///// 5 - Choc consommation transport + chauffage logement ////////
            // Oil consumption: -50% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports)  
            Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*0.95 + Proj_Vol.C.val(2)*0.78*0.5;


            ///// 6 - Choc consommation de biens manufacturés ////////
            // Secteur OthEq: -20% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13) = Proj_Vol.C.val(13)*0.8;

        
        elseif with_sufficiency_behaviour=="Construction X Chauffage X Gaspillage alimentaire X Achat vehicules neufs X Deplacements X OthEq X Electromenager"

            ////// 1 - Choc Construction durable et Zéro artificialisation nette ////////
            // Construction: -50% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21) = Proj_Vol.C.val(21)*0.5;

        
            ///// 2 - Choc consommation énergétique des ménages sur le logement ////////
            // Oil consumption: -5% de la consommation du logement (22 % consommation oil est issue des logements /78 % des transports)  
            // Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*0.95 + Proj_Vol.C.val(2)*0.78*1;

            // Gas consumption: -5% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3) = Proj_Vol.C.val(3)*0.95;

            // Coal consumption: -5% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4) = Proj_Vol.C.val(4)*0.95;

            // Electricity consumption: -5% de la consommation du logement (100% de la consommation électricité issue du logement)
            Proj_Vol.C.val(5) = Proj_Vol.C.val(5)*0.95;


            ///// 3 - Choc Alimentation et Gaspillage alimentaire /////
            // Alimentation: -20% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15) = Proj_Vol.C.val(15)*0.8;

            // Agriculture: -20% de la production agricole du à la réduction du gaspillage alimentaire
            Proj_Vol.C.val(20) = Proj_Vol.C.val(20)*0.8;


            ///// 4 - Choc véhicules neufs////////
            // Secteur automobile: -50% d’achats de véhicules neufs 
            Proj_Vol.C.val(12) = Proj_Vol.C.val(12)*0.5;

            ///// 5 - Choc consommation transport + chauffage logement ////////
            // Oil consumption: -50% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports)  
            Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*0.95 + Proj_Vol.C.val(2)*0.78*0.5;

            ///// 6 - Choc consommation de biens manufacturés ////////
            // Secteur OthEq: -20% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13) = Proj_Vol.C.val(13)*0.8;

            // Secteur Electroménager: -20% de consommation électroménager
            Proj_Vol.C.val(14) = Proj_Vol.C.val(14)*0.8;

        
        elseif with_sufficiency_behaviour=="Construction X Chauffage X Gaspillage alimentaire X Achat vehicules neufs X Deplacements X OthEq X Electromenager X OtherManufacturedGoods"

            ////// 1 - Choc Construction durable et Zéro artificialisation nette ////////
            // Construction: -50% de la construction neuve avec la zero artificialisation des sols
            Proj_Vol.C.val(21) = Proj_Vol.C.val(21)*0.5;

        
            ///// 2 - Choc consommation énergétique des ménages sur le logement ////////
            // Oil consumption: -5% de la consommation du logement (22 % consommation oil est issue des logements /78 % des transports)  
            // Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*0.95 + Proj_Vol.C.val(2)*0.78*1;

            // Gas consumption: -5% de la consommation du logement (100 % consommation gaz issue du logement)
            Proj_Vol.C.val(3) = Proj_Vol.C.val(3)*0.95;

            // Coal consumption: -5% de la consommation du logement (100 % de la consommation du charbon est issue du logement)
            Proj_Vol.C.val(4) = Proj_Vol.C.val(4)*0.95;

            // Electricity consumption: -5% de la consommation du logement (100% de la consommation électricité issue du logement)
            Proj_Vol.C.val(5) = Proj_Vol.C.val(5)*0.95;


            ///// 3 - Choc Alimentation et Gaspillage alimentaire /////
            // Alimentation: -20% car on réduit fortement le gaspillage alimentaire
            Proj_Vol.C.val(15) = Proj_Vol.C.val(15)*0.8;

            // Agriculture: -20% de la production agricole du à la réduction du gaspillage alimentaire
            Proj_Vol.C.val(20) = Proj_Vol.C.val(20)*0.8;


            ///// 4 - Choc véhicules neufs////////
            // Secteur automobile: -50% d’achats de véhicules neufs 
            Proj_Vol.C.val(12) = Proj_Vol.C.val(12)*0.5;

            ///// 5 - Choc consommation transport + chauffage logement ////////
            // Oil consumption: -50% de la consommation du transport (22 % consommation oil est issue des logements /78 % des transports)  
            Proj_Vol.C.val(2) = Proj_Vol.C.val(2)*0.22*0.95 + Proj_Vol.C.val(2)*0.78*0.5;


            ///// 6 - Choc consommation de biens manufacturés ////////
            // Secteur OthEq: -20% de consommation TV, ordi, smartphone
            Proj_Vol.C.val(13) = Proj_Vol.C.val(13)*0.8;

            // Secteur Electroménager: -20% de consommation électroménager
            Proj_Vol.C.val(14) = Proj_Vol.C.val(14)*0.8;

            // Secteur OtherManufacturedGoods: -20% de consommation de vêtements, autres biens manufacturés,...
            Proj_Vol.C.val(16) = Proj_Vol.C.val(16)*0.8;

        end
    end
end