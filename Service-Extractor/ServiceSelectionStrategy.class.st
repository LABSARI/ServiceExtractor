"
I am responsible for the selection of the next service to extract at each increment.
I use a granularity strategy.
"
Class {
	#name : 'ServiceSelectionStrategy',
	#superclass : 'SimulationStrategy',
	#category : 'Service-Extractor-Simulation',
	#package : 'Service-Extractor',
	#tag : 'Simulation'
}

{ #category : 'computing' }
ServiceSelectionStrategy >> nextMethodsToExtract [

	self subclassResponsibility
]
