"
I am responsible for the end strategy of the migration, when the migration meets the requirements.
"
Class {
	#name : 'ServiceEndStrategy',
	#superclass : 'SimulationStrategy',
	#category : 'Service-Extractor-Simulation',
	#package : 'Service-Extractor',
	#tag : 'Simulation'
}

{ #category : 'computing' }
ServiceEndStrategy >> migrationIsOver [

	^ simulation entryMethods isEmpty
]
