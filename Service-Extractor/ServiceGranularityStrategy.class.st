"
I am responsible for the granularity strategy.
The granularity refers to the number of methods that should be extracted as a service.
The extracted service should have a decent cohesion.
"
Class {
	#name : 'ServiceGranularityStrategy',
	#superclass : 'SimulationStrategy',
	#category : 'Service-Extractor-Simulation',
	#package : 'Service-Extractor',
	#tag : 'Simulation'
}

{ #category : 'computing' }
ServiceGranularityStrategy >> methodsToExtractTogether [
	
	self subclassResponsibility
]

{ #category : 'computing' }
ServiceGranularityStrategy >> metric [
	"The metric used to regroup methods together as a service"
	self subclassResponsibility
]
