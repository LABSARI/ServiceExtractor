"
This class represents an extracted service.
"
Class {
	#name : 'Service',
	#superclass : 'Object',
	#instVars : [
		'dominatedMethods',
		'duplicatedMethods',
		'allMethods'
	],
	#category : 'Service-Extractor-Model',
	#package : 'Service-Extractor',
	#tag : 'Model'
}

{ #category : 'accessing' }
Service >> allMethods [

	^ allMethods
]

{ #category : 'accessing' }
Service >> allMethods: anObject [

	allMethods := anObject
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
