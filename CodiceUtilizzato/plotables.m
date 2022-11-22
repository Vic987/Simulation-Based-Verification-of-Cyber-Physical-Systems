% Plotting --- Istruzioni
% 	
%	i --- Cambiare questo valore se si vuole plottare una delle seguenti tabelle:
%		Valore 1 = TabellaRisultatiTest; 
%		Valore 2 = TabellaTempiRAMTest;
%		Valore diverso da 1 o 2 = test_resultj
%
%	j --- Cambiare questo valore se si vuole plottare valori differenti a seconda della i
%		CASO i=1
%			j = 1 --> Intervallo di tempo
%			j = 2 --> EngineRPM
%			j = 3 --> Velocità
%			j != 1,2,3 --> Entità della violazione
%		CASO i=2
%			j = 1 --> Tempo di esecuzione contro-esempio
%			j = 2 --> Tempo di CPU
%			j = 3 --> RAM utilizzata da Matlab
%			j != 1,2,3 --> Prove svolte da Nomad
%		CASO i!=1,2
%			j funzionerà come parte finale di test_result (es: j=7 --> test_result7.csv)

i = 2; % Cambia nel caso vuoi plottare una tabella diversa
j = 3; % Cambia nel caso vuoi plottare diversi valori

if(i==1)
	table = readtable("TabellaRisultatiTest.csv");
	if(j == 1)
		plot([1:height(table)], [table.(1)], "Marker", ".");
		title("Intervallo di tempo utilizzato");
		xlabel("N° Test");
		ylabel("Secondi (s)");
		legend("Tempo (in secondi)", "Location", "southwest");
	elseif(j == 2)
		plot([1:height(table)], [table.(2),table.(5)], "Marker", ".");
		title("Numero di giri del motore");
		xlabel("N° Test");
		ylabel("RPM");
		legend("Engine RPM iniziale", "Engine RPM contro-esempio", "Location", "southwest");
	elseif(j == 3)
		plot([1:height(table)], [table.(3),table.(6)], "Marker", ".");
		title("Velocità");
		xlabel("N° Test");
		ylabel("Km/h");
		legend("Velocità iniziale", "Velocità contro-esempio", "Location", "southwest");
	else
		plot([1:height(table)], [table.(4),table.(7)], "Marker", ".");
		title("Entità della violazione");
		xlabel("N° Test");
		ylabel("Percentuale (%)");
		legend("Entità violazione iniziale", "Entità violazione contro-esempio", "Location", "southwest");
	end
elseif(i==2)
	table = readtable("TabellaTempiRAMTest.csv");
	if(j == 1)
		plot([1:height(table)], [table.(4)], "Marker", ".");
		title("Tempo di esecuzione contro-esempio");
		xlabel("N° Test");
		ylabel("Secondi (s)");
		legend("Tempo (in secondi)", "Location", "southwest");
	elseif(j == 2)
		plot([1:height(table)], [table.(2), table.(3)], "Marker", ".");
		title("Tempo di CPU");
		xlabel("N° Test");
		ylabel("Secondi (s)");
		legend("Tempo CPU random input", "Tempo CPU contro-esempio", "Location", "southwest");
	elseif(j == 3)
		plot([1:height(table)], [table.(5)], "Marker", ".");
		title("RAM utilizzata da MATLAB");
		xlabel("N° Test");
		ylabel("Memoria (KB)");
		legend("Memoria (in kilobyte)", "Location", "southwest");
	else
		plot([1:height(table)], [table.(5)], "Marker", ".");
		title("Prove svolte Nomad");
		xlabel("N° Test");
		ylabel("N° Prove");
		legend("Quantità delle prove", "Location", "southwest");
	end
else
	table = readtable("test_result"+j+".csv");
	plot([table.(1)], [table.(2),table.(3)], "Marker", ".");
	title("Input random e contro-esempio a confronto");
	xlabel("Tempo");
	ylabel("%% di acceleratore");
	legend("Throttle random input", "Throttle contro-esempio", "Location", "southwest");
end

x0=20;
y0=20;
width=850;
height=700;
set(gcf,'position',[x0,y0,width,height]);

clear;
