#!/bin/bash
# GPU
# Odessa      : m148 m149 m150
# ANR METADATV: m173
# ANR PLUMCOT : m174 m175

###
# SEUILS A MODIFIER
# Temps entre 2 vérifications
sleep_time=5m
# Temps entre 2 soumission à une machine
sleep_time_computer=10s
# Taux d'occupation à ne pas dépassser
seuil_cpu=50 #0.7
seuil_gpu=0.5
seuil_mem=0.5
###

pas=1
#for f in {0..9..$pas} # ATTENTION la fin est incluse !!! 

verif_and_execute () {
    assign=0
    while [ $assign -eq 0 ]
    do
        #echo $assign
        for m in m148 m153 m154 m155 m156 m157 m158 m159 m160 m161 #m149 m150 m173 m174 m175 m162 m163 m164 m165 m166 m168 m169
        do
            #echo $m
            load_cpu=$(ssh $m "cut -d ' ' -f2 /proc/loadavg")
            nb_cpu=$(ssh $m "grep -c ^processor /proc/cpuinfo")
            load_cpu_percent=$(echo $load_cpu / $nb_cpu | bc -l)
            #echo $load_cpu_percent
            if [ $(echo $load_cpu_percent'<'$seuil_cpu | bc -l) -eq 1 ]
            then
                #ssh $m dvd_extraction_git/dvd_extraction/launch_rip.sh $name $season $first $last $ix &
                echo "Tâche assignée à" $m
                assign=1
                continue 2
            fi
        done
        sleep $sleep_time
    done
}

IFS_old=$IFS
IFS=$(echo -en "\n\b")
for row in $(cat $1);
do
    echo "I got:$row"
    #verif_and_execute
    assign=0
    while [ $assign -eq 0 ]
    do
        #echo $assign
        for m in m153 m154 m155 m156 m157 m158 m159 m160 m161 m164 m165 m166 m168 m169 #m148 m149 m150 m173 m174 m175 m162 m163 m164 m165 m166 m168 m169
        do
            #echo $m
            #load_cpu=$(ssh $m "cut -d ' ' -f2 /proc/loadavg")
            #nb_cpu=$(ssh $m "grep -c ^processor /proc/cpuinfo")
            load_cpu_percent=$(ssh $m "./get_load_cpu.sh") #$(ssh $m "echo $[100-$(vmstat 1 2|tail -1|awk '{print $15}')]") #$(echo $load_cpu / $nb_cpu | bc -l)
            echo $m $load_cpu_percent
            if [ $(echo $load_cpu_percent'<'$seuil_cpu | bc -l) -eq 1 ]
            then
                ssh $m dvd_extraction_git/dvd_extraction/launch_rip.sh $row &
                echo "Tâche assignée à" $m
                sleep $sleep_time_computer
                assign=1
                continue 2
            fi
        done
        sleep $sleep_time
    done
done
IFS=IFS_old
