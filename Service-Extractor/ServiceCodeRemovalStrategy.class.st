"
I am responsible for the stragety of code removal after an increment of the migration.
"
Class {
	#name : 'ServiceCodeRemovalStrategy',
	#superclass : 'SimulationStrategy',
	#category : 'Service-Extractor-Simulation',
	#package : 'Service-Extractor',
	#tag : 'Simulation'
}

{ #category : 'as yet unclassified' }
ServiceCodeRemovalStrategy >> methodsToRemove [
	
	self subclassResponsibility
]
