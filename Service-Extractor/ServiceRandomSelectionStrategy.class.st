Class {
	#name : 'ServiceRandomSelectionStrategy',
	#superclass : 'ServiceSelectionStrategy',
	#instVars : [
		'methods'
	],
	#category : 'Service-Extractor-Simulation',
	#package : 'Service-Extractor',
	#tag : 'Simulation'
}

{ #category : 'accessing' }
ServiceRandomSelectionStrategy >> methods [

	^ methods ifNil: [ methods := simulation entryMethods ]
]

{ #category : 'computing' }
ServiceRandomSelectionStrategy >> nextMethodsToExtract [
	
	| ms |
	ms := self methods asOrderedCollection shuffle first: 4.

	self methods removeAll: ms.

	^ ms
]
