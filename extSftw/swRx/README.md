**Feature features TBI**

---------- ALEX MINETTO
1. Integration of Self-Adaptive Iterative Algorithm (SAIA) in LMS routine
2. Extension WLMS with different weighting strategies
3. Integration of auxiliary measurements interface


TODO
====

# Coherent int. time extension in acquisition
- The setting is available but a multihypotesis strategy to avoid bit transition must be put in place. Moreover the acqusiiton threshold takes into account Pfa and K, but not Tcoh.

# song-L1 starter pack
- include a binary file equipped with metadata (e.g. duration, which PRN, ect)

# PVT development [ITALIAN]
- I canali vengono inizializzati sequenzialmente ma se fallisce l'individuazione del preambolo la numerazione degli stessi non è continua. Spesso è usata come indicizzazione nei cicli e la "scomparsa di canali" può causare problemi.
- Sistemare la gestione del Tc (tempo integrazione coerente fissato dall'utente). Si propone la creazione di un settingsChecker che esegua una verifica dei parametri inseriti dall'utente 
- Particle non stabile in condizioni critiche [dataset specifico con 4 satelliti)

