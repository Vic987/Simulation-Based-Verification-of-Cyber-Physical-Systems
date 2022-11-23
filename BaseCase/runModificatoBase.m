% Input: Throttle (=acceleratore; range: [0;100]; viene considerata come %) & Brake (=freno; range: [0;100]; viene considerata come %; verrà sempre settato a 0)
% Ouput: EngineRPM (= numero giri motore), Velocità (= km/h)
% Funzione: distanza
% Obiettivo: Falsificare il caso base
% Intervallo: 60,120,180,240,300 secondi
% Tempo T: 0.04 secondi

% In questa prova, vogliamo notare come lo svolgimento può essere fatto dividendo i vari parametri di Throttle.
% La divisione è stata fatta con gli intervalli prefissati inizialmente.
% Questi parametri, verranno poi simulati da Nomad per l'ottimizzazione (Nomad ottimizzerà ogni 6 parametri)
% N.B: Nomad non permette l'ottimizzazione se si danno in input più di 50 parametri.
% Ricordiamo che Nomad ottimizza nel seguente modo: min(f(x)).

% Funzioni che creano dei valori casuali per throttle ogni secondo, e un intervallo di tempo casuale;

%brake_random = [0;double(uint8((100)*rand(119,1)))];


divisori = [];
random = 29;

default = [0:random];
throttle_random = [0;double(uint8((100)*rand(random,1)))];

% Creazione dei set di acceleratore e freno per poi utilizzarlo nel Dataset.
% I primi valori('throttle/brake_random') si riferiscono alla percentuale di acceleratore/freno utilizzato (valori random);
% Il secondo (parametro 'random') si riferisce al tempo (intervallo)
throttle_set = timeseries(throttle_random, default, 'Name', 'Throttle'); 
brake_set = timeseries(zeros(random+1, 1), default, 'Name', 'Brake'); 

% Creazione Dataset 'Personalizzato1' per il funzionamento dell'acceleratore e del freno all'interno del progetto Simulink
Personalizzato1 = Simulink.SimulationData.Dataset;
Personalizzato1 = addElement(Personalizzato1, throttle_set);
Personalizzato1 = addElement(Personalizzato1, brake_set);

% Salvataggio nuovo Dataset (Se già esistente, lo sovrascrive)
save("/home/daniele/Scaricati/Simulink/examples/simulink_automotive/main/ManovreVeicolo.mat", 'Personalizzato1');

% Utiliziamo lo scenario 'Personalizzato1' appena creato, e simuliamo il tutto su Simulink (chiamata 'sim(...)').
tempoCPUin = cputime;
sldemo_autotrans_output = sim('sldemo_autotrans','StopTime',""+(random+1)).sldemo_autotrans_output;
tempoCPUin = cputime - tempoCPUin;

maxRPM_iniziale = max(sldemo_autotrans_output{1}.Values.Data);
maxV_iniziale = max(sldemo_autotrans_output{8}.Values.Data);

% Calcoliamo l'entità di violazione iniziale (ovvero, se il sistema è già violato)
ent_viol = 0;
for i = 1:25:25*(random+2)
	rpm = round(sldemo_autotrans_output{1}.Values.Data(i)); 					 
	kmh = round(sldemo_autotrans_output{8}.Values.Data(i));							
	ent_new_viol = sqrt(max((kmh-120)/120, 0)^2 + max((rpm-4500)/4500, 0)^2);            
	if(ent_new_viol > ent_viol)
		ent_viol =  ent_new_viol;
	end
end

% SIMULAZIONE CON NOMAD

% Parametri aggiuntivi per Nomad; Per semplificare lo svolgimento, salviamo l'intervallo come variabile fissa su Nomad
params = struct('BB_OUTPUT_TYPE','OBJ','FIXED_VARIABLE', convertStringsToChars(""+6)); 

lb = zeros(6+1, 1); % LowerBound di Throttle
ub = [lb(1:6)+100; 300]; % UpperBound di Throttle

soluzioni_Throttle = [];
%soluzioni_Brake = [];

bbval = 0; % Tentativi totali Nomad
tempoWALL = tic;

% Valori iniziali di Throttle prima dell'ottimizzazione;
x0 = [throttle_random(1:6);random];
	
% x conterrà i parametri di Throttle dopo l'ottimizzazione con Nomad.
% f conterrà la DISTANZA ottimizzata con Nomad.
[x,f,ef,iter,nfval] = nomadOpt(@blackbox,x0,lb,ub,params);
	
bbval = bbval+nfval;
	
if(f == -0 || f == 0)
	soluzioni_Throttle = cat(1, soluzioni_Throttle, x0(1:length(x0)-1));
else
	soluzioni_Throttle = cat(1, soluzioni_Throttle, round(x(1:length(x)-1)));
end
%soluzioni_Brake = cat(1, soluzioni_Brake, round(x(25:48), 0));
soluzioni_Throttle = repelem(soluzioni_Throttle, 5);

tempoWALL = toc(tempoWALL); % Tempo di esecuzione

% Calcolo RAM usage
[status, output] = system("pmap "+feature("getpid")+" | grep total | awk '/[0-9]K/{print $2}'");
output = str2double(output(1:length(output)-2));

% Esportiamo i dati di Nomad e verifichiamo la falsificazione

% Creazione dei set di acceleratore e freno per poi utilizzarlo nel Dataset.
% I primi valori('throttle/brake_random') si riferiscono alla percentuale di acceleratore/freno utilizzato (valori Nomad);
% Il secondo (parametro 'random') si riferisce al tempo (intervallo)
throttle_set = timeseries(soluzioni_Throttle, default, 'Name', 'Throttle');
brake_set = timeseries(zeros(random+1, 1), default, 'Name', 'Brake'); 

% Creazione Dataset 'Personalizzato1' per il funzionamento dell'acceleratore e del freno all'interno del progetto Simulink
Personalizzato1 = Simulink.SimulationData.Dataset;
Personalizzato1 = addElement(Personalizzato1, throttle_set);
Personalizzato1 = addElement(Personalizzato1, brake_set);

% Salvataggio nuovo Dataset (Se già esistente, lo sovrascrive)
save("/home/daniele/Scaricati/Simulink/examples/simulink_automotive/main/ManovreVeicolo.mat", 'Personalizzato1');

% Utiliziamo lo scenario 'Personalizzato1' appena creato, e simuliamo il tutto su Simulink (chiamata 'sim(...)').
tempoCPUout = cputime;
sldemo_autotrans_output_optimized = sim('sldemo_autotrans','StopTime',""+(random+1)).sldemo_autotrans_output;
tempoCPUout = cputime - tempoCPUout;

maxRPM_finale = max(sldemo_autotrans_output_optimized{1}.Values.Data);
maxV_finale = max(sldemo_autotrans_output_optimized{8}.Values.Data);

% Calcoliamo l'entità di violazione (Contro-esempio di Nomad)
ent_viol_opt = 0;
for i = 1:25:25*(random+2)
	rpm = round(sldemo_autotrans_output_optimized{1}.Values.Data(i));					
	kmh = round(sldemo_autotrans_output_optimized{8}.Values.Data(i));					
	ent_new_viol_opt = sqrt(max((kmh-120)/120, 0)^2 + max((rpm-4500)/4500, 0)^2);               
	if(ent_new_viol_opt > ent_viol_opt)
		ent_viol_opt = ent_new_viol_opt;  
	end
end

% Stampa di tutti i risultati

j = 1;
while(isfile("test_result"+j+".csv"))
	j = j+1;
end

writematrix(["Tempo", "Throttle_Random_Iniziale", "Throttle_ControEsempio"], "test_result"+j+".csv", "Delimiter", ",");
writematrix(cat(2, cat(2, rot90(default, 3), throttle_random), soluzioni_Throttle), "test_result"+j+".csv", "Delimiter", ",", "WriteMode", "append");

if(isfile("TabellaRisultatiTest0.csv")) 
	writematrix([random+1, maxRPM_iniziale, maxV_iniziale, ent_viol, maxRPM_finale, maxV_finale, ent_viol_opt], "TabellaRisultatiTest0.csv", "Delimiter", ",", "WriteMode", "append");
else
	writematrix(["Intervallo_Temporale_utilizzato", "EngineRPM_Massimo_Con_Random_Input", "Velocita_Massima_Con_Random_Input", "Entita_Violazione_Con_Random_Input (%)", "EngineRPM_Massimo_ControEsempio", "Velocita_Massima_ControEsempio", "Entita_Violazione_ControEsempio (%)"], "TabellaRisultatiTest0.csv");
	writematrix([random+1, maxRPM_iniziale, maxV_iniziale, ent_viol, maxRPM_finale, maxV_finale, ent_viol_opt], "TabellaRisultatiTest0.csv", "Delimiter", ",", "WriteMode", "append");
end

if(isfile("TabellaTempiRAMTest0.csv"))
	writematrix([j, tempoCPUin, tempoCPUout, tempoWALL, output, bbval], "TabellaTempiRAMTest0.csv", "Delimiter", ",", "WriteMode", "append");
else
	writematrix(["N° Test", "Tempo_Di_CPU_Con_Random_Input", "Tempo_Di_CPU_ControEsempio", "Tempo_Di_Esecuzione_Nomad_Intero_ControEsempio", "RAM_Utilizzata_da_MATLAB_per_il_processo (KB)", "Prove_Totali_Svolte_Da_Nomad"], "TabellaTempiRAMTest0.csv");
	writematrix([j, tempoCPUin, tempoCPUout, tempoWALL, output, bbval], "TabellaTempiRAMTest0.csv", "Delimiter", ",", "WriteMode", "append");
end

clear;
