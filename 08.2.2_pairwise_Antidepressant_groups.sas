options validvarname=V7;

/* Import data*/ 
PROC IMPORT DATAFILE='/home/u63442842/MED_ND/08_final_20251023/final_sample_20251023.csv' 
            OUT=df 
            DBMS=CSV 
            REPLACE;
    GETNAMES=YES;
RUN;

proc contents data=df;
run;

proc datasets library=work nolist;
    modify df;
    rename hardBrakingCountperTrip=hardBrakperTri 
    hardCoreBrakingCountperTrip=hardCoreBrakperTri
    hardAccelerationCountperTrip=hardAccperTri
    overspeedingCountperTrip = overspeedperTri;
quit;


%macro run_lme(outcome);
/* Intercept*/
	PROC MIXED DATA=df METHOD=MIVQUE0 MAXITER=1000 NOCLPRINT=10 
			COVTEST /*NOITPRINT*/;
		CLASS id antidepressant_group(ref='1') gender race No_antidepressant_CNS_drugs_ever(ref='0') Antidiabetics_ever(ref='0');
		MODEL &outcome=month_index antidepressant_group month_index*antidepressant_group 
		age educ gender race pacc ADI_NATRANK quan acuityfarbv2score acuitynearbv2score No_antidepressant_CNS_drugs_ever Antidiabetics_ever/noint DDFM=satterth SOLUTION 
			/*CHISQ CL*/;
		RANDOM intercept month_index/SUBJECT=id TYPE=UN;
		estimate '2 - 1' antidepressant_group 1 0 0 0 0 -1/E cl; 
		estimate '2 - 3' antidepressant_group 1 -1 0 0 0 0/E cl; 
		estimate '2 - 4' antidepressant_group 1 0 -1 0 0 0/E cl; 
		estimate '2 - 5' antidepressant_group 1 0 0 -1 0 0/E cl; 
		estimate '2 - 6' antidepressant_group 1 0 0 0 -1 0/E cl; 
		
		estimate '3 - 1' antidepressant_group 0 1 0 0 0 -1/E cl; 
		estimate '3 - 4' antidepressant_group 0 1 -1 0 0 0/E cl; 
		estimate '3 - 5' antidepressant_group 0 1 0 -1 0 0/E cl; 
		estimate '3 - 6' antidepressant_group 0 1 0 0 -1 0/E cl; 
		
		estimate '4 - 1' antidepressant_group 0 0 1 0 0 -1/E cl; 
		estimate '4 - 5' antidepressant_group 0 0 1 -1 0 0/E cl; 
		estimate '4 - 6' antidepressant_group 0 0 1 0 -1 0/E cl; 
		
		estimate '5 - 1' antidepressant_group 0 0 0 1 0 -1/E cl; 
		estimate '5 - 6' antidepressant_group 0 0 0 1 -1 0/E cl; 
		
		estimate '6 - 1' antidepressant_group 0 0 0 0 1 -1/E cl; 
		
		TITLE1 "TEST for Y-intercept - &outcome";
	RUN;

/* Slope*/
	PROC MIXED DATA=df METHOD=MIVQUE0 MAXITER=1000 NOCLPRINT=10 
			COVTEST /*NOITPRINT*/;
		CLASS id antidepressant_group(ref='1')  gender race No_antidepressant_CNS_drugs_ever(ref='0') Antidiabetics_ever(ref='0');
		MODEL &outcome=antidepressant_group month_index*antidepressant_group 
			  age educ gender race pacc ADI_NATRANK quan acuityfarbv2score acuitynearbv2score No_antidepressant_CNS_drugs_ever Antidiabetics_ever
		/DDFM=satterth SOLUTION CHISQ CL;
		RANDOM intercept month_index/SUBJECT=id TYPE=UN;
		estimate '2 - 1' month_index*antidepressant_group 1 0 0 0 0 -1/E cl; 
		estimate '2 - 3' month_index*antidepressant_group 1 -1 0 0 0 0/E cl; 
		estimate '2 - 4' month_index*antidepressant_group 1 0 -1 0 0 0/E cl; 
		estimate '2 - 5' month_index*antidepressant_group 1 0 0 -1 0 0/E cl; 
		estimate '2 - 6' month_index*antidepressant_group 1 0 0 0 -1 0/E cl; 
		
		estimate '3 - 1' month_index*antidepressant_group 0 1 0 0 0 -1/E cl; 
		estimate '3 - 4' month_index*antidepressant_group 0 1 -1 0 0 0/E cl; 
		estimate '3 - 5' month_index*antidepressant_group 0 1 0 -1 0 0/E cl; 
		estimate '3 - 6' month_index*antidepressant_group 0 1 0 0 -1 0/E cl; 
		
		estimate '4 - 1' month_index*antidepressant_group 0 0 1 0 0 -1/E cl; 
		estimate '4 - 5' month_index*antidepressant_group 0 0 1 -1 0 0/E cl; 
		estimate '4 - 6' month_index*antidepressant_group 0 0 1 0 -1 0/E cl; 
		
		estimate '5 - 1' month_index*antidepressant_group 0 0 0 1 0 -1/E cl; 
		estimate '5 - 6' month_index*antidepressant_group 0 0 0 1 -1 0/E cl; 
		
		estimate '6 - 1' month_index*antidepressant_group 0 0 0 0 1 -1/E cl; 
		
		TITLE1 "Test for slope - &outcome";
	RUN;

%mend run_lme;
%run_lme(Uni_dest);

/* Running LME for Each Outcome Variable */
%run_lme(tripCount);
%run_lme(avgSpeed);
%run_lme(distanceTravelledMax);
%run_lme(dayTripTotal);
%run_lme(nightTripTotal);
%run_lme(tripCountLT1mile);
%run_lme(tripCount1to5miles);
%run_lme(tripCount5to10miles);
%run_lme(tripCount10to20miles);
%run_lme(tripCount20plusmiles);
%run_lme(nDaysDriven);
%run_lme(hardBrakperTri);
%run_lme(hardAccperTri);
%run_lme(overspeedperTri);
%run_lme(corneringCountperTrip);
%run_lme(radiusOfGyration);
%run_lme(randomEntropy);
%run_lme(Uni_dest);

quit;