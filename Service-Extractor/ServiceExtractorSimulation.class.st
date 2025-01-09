"
This class is used to simulate extractions from a monolith and gather information about the simulation.

Several strategies are available:
	- to select next method(s) to extract,
	- to select the granularity of the extracted service,
	- to remove dead code from the monolith.
"
Class {
	#name : 'ServiceExtractorSimulation',
	#superclass : 'Object',
	#instVars : [
		'serviceExtractor',
		'endStrategy',
		'granularityStrategy',
		'entryMethods',
		'removedMethods',
		'selectionStrategy',
		'codeRemovalStrategy',
		'currentExtraction',
		'previousExtractions',
		'allExtractedMethods',
		'model'
	],
	#category : 'Service-Extractor-Simulation',
	#package : 'Service-Extractor',
	#tag : 'Simulation'
}

{ #category : 'accessing' }
ServiceExtractorSimulation >> allExtractedMethods [

	^ allExtractedMethods
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> allExtractedMethods: anObject [

	allExtractedMethods := anObject
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> codeRemovalStrategy [

	^ codeRemovalStrategy
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> codeRemovalStrategy: anObject [

	codeRemovalStrategy := anObject.
	codeRemovalStrategy simulation: self
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> currentExtraction [

	^ currentExtraction
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> dominatedMethods [
	"Should we compute domination analysis at each increment? Because some methods are removed and the domination could change."

	^ uccg dominatedMethodsFromMethods:
		  currentExtraction extractedMethods
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> endStrategy [

	^ endStrategy
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> endStrategy: anObject [

	endStrategy := anObject.
	endStrategy simulation: self
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> entryMethods [

	^ entryMethods 
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> entryMethods: anObject [

	entryMethods := anObject
]

{ #category : 'computing' }
ServiceExtractorSimulation >> executeSimulation [

	[ self migrationIsOver ] whileFalse: [ 
		self extractNextService
	 ]
]

{ #category : 'computing' }
ServiceExtractorSimulation >> extractNextService [

	| methods rms |
	currentExtraction := ExtractionSimulation new.
	methods := self nextMethodsToExtract.
	currentExtraction
		extractedMethods: methods;
		extractedService: (ServiceExtractor extractMethods: methods).
		
	rms := self removedMethods.
	currentExtraction	removedMethods: rms.
	removedMethods addAll: rms.
	allExtractedMethods addAll: methods.
	previousExtractions add: currentExtraction.

	entryMethods removeAll: methods
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> granularityStrategy [

	^ granularityStrategy
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> granularityStrategy: anObject [

	granularityStrategy := anObject.
	granularityStrategy simulation: self
]

{ #category : 'initialization' }
ServiceExtractorSimulation >> initialize [

	super initialize.
	previousExtractions := OrderedCollection new.
	removedMethods := OrderedCollection new.
	allExtractedMethods := OrderedCollection new
]

{ #category : 'computing' }
ServiceExtractorSimulation >> migrationIsOver [

	^ endStrategy migrationIsOver 
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> model [

	^ model
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> model: anObject [

	model := anObject
]

{ #category : 'computing' }
ServiceExtractorSimulation >> nextMethodsToExtract [

	^ selectionStrategy nextMethodsToExtract
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> previousExtractions [

	^ previousExtractions
]

{ #category : 'computing' }
ServiceExtractorSimulation >> removedMethods [

	^ codeRemovalStrategy methodsToRemove
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> selectionStrategy [

	^ selectionStrategy
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> selectionStrategy: anObject [

	selectionStrategy := anObject.
	selectionStrategy simulation: self
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> serviceExtractor [

	^ serviceExtractor
]

{ #category : 'accessing' }
ServiceExtractorSimulation >> serviceExtractor: anObject [

	serviceExtractor := anObject
]
