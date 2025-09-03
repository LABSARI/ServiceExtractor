"
This class represents the monolith state after an increment.
"
Class {
	#name : 'Monolith',
	#superclass : 'Object',
	#instVars : [
		'methods',
		'deletedMethods'
	],
	#category : 'Service-Extractor-Model',
	#package : 'Service-Extractor',
	#tag : 'Model'
}

{ #category : 'accessing' }
Monolith >> deletedMethods [

	^ deletedMethods
]

{ #category : 'accessing' }
Monolith >> deletedMethods: anObject [

	deletedMethods := anObject
]

{ #category : 'accessing' }
Monolith >> methods [

	^ methods
]

{ #category : 'accessing' }
Monolith >> methods: anObject [

	methods := anObject
]
