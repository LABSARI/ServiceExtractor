Class {
	#name : 'TypeGraphNode',
	#superclass : 'Object',
	#instVars : [
		'label',
		'famixEntity'
	],
	#category : 'Service-Extractor',
	#package : 'Service-Extractor'
}

{ #category : 'accessing' }
TypeGraphNode >> famixEntity [

	^ famixEntity
]

{ #category : 'accessing' }
TypeGraphNode >> famixEntity: anObject [

	famixEntity := anObject
]

{ #category : 'accessing' }
TypeGraphNode >> label [

	^ label
]

{ #category : 'accessing' }
TypeGraphNode >> label: anObject [

	label := anObject
]
