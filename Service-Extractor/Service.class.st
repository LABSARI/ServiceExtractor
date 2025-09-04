"
This class represents an extracted service.
"
Class {
	#name : 'Service',
	#superclass : 'Object',
	#instVars : [
		'dominatedMethods',
		'duplicatedMethods',
		'allMethods',
		'extractedMethods',
		'movedMethods',
		'candidateMethods'
	],
	#category : 'Service-Extractor-Model',
	#package : 'Service-Extractor',
	#tag : 'Model'
}

{ #category : 'accessing' }
Service >> allMethods [

	^ allMethods ifNil: [
		  allMethods := dominatedMethods , duplicatedMethods , movedMethods
		                , extractedMethods ]
]

{ #category : 'accessing' }
Service >> candidateMethods [

	^ candidateMethods
]

{ #category : 'accessing' }
Service >> candidateMethods: anObject [

	candidateMethods := anObject
]

{ #category : 'accessing' }
Service >> dominatedMethods [

	^ dominatedMethods
]

{ #category : 'accessing' }
Service >> dominatedMethods: anObject [

	dominatedMethods := anObject
]

{ #category : 'accessing' }
Service >> duplicatedMethods [

	^ duplicatedMethods
]

{ #category : 'accessing' }
Service >> duplicatedMethods: anObject [

	duplicatedMethods := anObject
]

{ #category : 'accessing' }
Service >> extractedMethods [

	^ extractedMethods
]

{ #category : 'accessing' }
Service >> extractedMethods: anObject [

	extractedMethods := anObject
]

{ #category : 'objectives' }
Service >> methodsInMonolith [

	^ candidateMethods \ movedMethods
]

{ #category : 'as yet unclassified' }
Service >> methodsToDelete [

	^ dominatedMethods , extractedMethods , movedMethods
]

{ #category : 'accessing' }
Service >> movedMethods [

	^ movedMethods
]

{ #category : 'accessing' }
Service >> movedMethods: anObject [

	movedMethods := anObject
]
