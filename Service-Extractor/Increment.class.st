"
This class represents an increment of the incremental migration.
"
Class {
	#name : 'Increment',
	#superclass : 'Object',
	#instVars : [
		'nextIncrement',
		'previousIncrement',
		'monolith',
		'extractedService',
		'extractedMethods'
	],
	#category : 'Service-Extractor-Model',
	#package : 'Service-Extractor',
	#tag : 'Model'
}

{ #category : 'accessing' }
Increment >> extractedMethods [

	^ extractedMethods
]

{ #category : 'accessing' }
Increment >> extractedMethods: anObject [

	extractedMethods := anObject
]

{ #category : 'accessing' }
Increment >> extractedService [

	^ extractedService
]

{ #category : 'accessing' }
Increment >> extractedService: anObject [

	extractedService := anObject
]

{ #category : 'accessing' }
Increment >> monolith [

	^ monolith
]

{ #category : 'accessing' }
Increment >> monolith: anObject [

	monolith := anObject
]

{ #category : 'accessing' }
Increment >> nextIncrement [

	^ nextIncrement
]

{ #category : 'accessing' }
Increment >> nextIncrement: anObject [

	nextIncrement := anObject
]

{ #category : 'accessing' }
Increment >> previousIncrement [

	^ previousIncrement
]

{ #category : 'accessing' }
Increment >> previousIncrement: anObject [

	previousIncrement := anObject
]
