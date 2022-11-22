function dist = bb(x)
	%violazione1 = 4501;
	%violazione2 = 121;
	
	% Lavorazione dei parametri ottenuti in input
	%throttle_opt = repelem(x, 3);
	%brake_opt = repelem(x(25:48), 5);
	randd = x(length(x));
	time_default = [0:randd];
	
	xx = x(1:length(x)-1);
	throttle_opt = repelem(xx, length(time_default)/length(xx));
	% Creazione dei set di acceleratore e freno per poi utilizzarlo nel Dataset.
	% I primi valori('throttle/brake_opt') si riferiscono alla percentuale di acceleratore/freno utilizzato (valori random);
	% Il secondo (parametro 'time_default') si riferisce al tempo (intervallo)
	throttle_set = timeseries(throttle_opt, time_default, 'Name', 'Throttle'); 
	brake_set = timeseries(zeros(length(time_default), 1), time_default, 'Name', 'Brake'); 

	% Creazione Dataset 'Personalizzato1' per il funzionamento dell'acceleratore e del freno all'interno del progetto Simulink
	Personalizzato1 = Simulink.SimulationData.Dataset;
	Personalizzato1 = addElement(Personalizzato1, throttle_set);
	Personalizzato1 = addElement(Personalizzato1, brake_set);
	
	% Salvataggio nuovo Dataset (Se già esistente, lo sovrascrive)
	save("/home/daniele/Scaricati/Simulink/examples/simulink_automotive/main/ManovreVeicolo.mat", 'Personalizzato1');
	
	% Utiliziamo lo scenario 'Personalizzato1' appena creato, e simuliamo il tutto su Simulink (chiamata 'sim(...)').
	sldemo_autotrans_output1 = sim('sldemo_autotrans','StopTime',""+length(time_default)).sldemo_autotrans_output;
	
	% Punto cruciale per trovare il controesempio
	
	dist = 0;

	for i = 1:25:25*(length(time_default)+1)
		rpm = round(sldemo_autotrans_output1{1}.Values.Data(i));
		kmh = round(sldemo_autotrans_output1{8}.Values.Data(i));
		new_dist = sqrt(max((kmh-120)/120, 0)^2 + max((rpm-4500)/4500, 0)^2);					
		if(new_dist > dist)
			dist = new_dist;
		end
	end
	
	dist = -dist;
end
