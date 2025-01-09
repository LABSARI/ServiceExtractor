"
I am an extraction used in the service extractor simulation.
I contain information about an extraction:
	- Extracted methods
	- Removed methods
	- Duplicated methods
	- Extracted service
"
Class {
	#name : 'ExtractionSimulation',
	#superclass : 'Object',
	#instVars : [
		'removedMethods',
		'extractedMethods',
		'extractedService',
		'duplicatedMethods'
	],
	#category : 'Service-Extractor-Simulation',
	#package : 'Service-Extractor',
	#tag : 'Simulation'
}

{ #category : 'accessing' }
ExtractionSimulation >> duplicatedMethods [

	^ duplicatedMethods
]

{ #category : 'accessing' }
ExtractionSimulation >> duplicatedMethods: anObject [

	duplicatedMethods := anObject
]

{ #category : 'accessing' }
ExtractionSimulation >> extractedMethods [

	^ extractedMethods
]

{ #category : 'accessing' }
ExtractionSimulation >> extractedMethods: anObject [

	extractedMethods := anObject
]

{ #category : 'accessing' }
ExtractionSimulation >> extractedService [

	^ extractedService
]

{ #category : 'accessing' }
ExtractionSimulation >> extractedService: anObject [

	extractedService := anObject
]

{ #category : 'accessing' }
ExtractionSimulation >> removedMethods [

	^ removedMethods
]

{ #category : 'accessing' }
ExtractionSimulation >> removedMethods: anObject [

	removedMethods := anObject
]
