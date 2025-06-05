Class {
	#name : 'FamixJavaSourceAnchorSE',
	#superclass : 'FamixJavaSourceAnchor',
	#instVars : [
		'customSourceText'
	],
	#category : 'Service-Extractor-Extractor',
	#package : 'Service-Extractor',
	#tag : 'Extractor'
}

{ #category : 'accessing' }
FamixJavaSourceAnchorSE >> customSourceText: anObject [

	customSourceText := anObject
]

{ #category : 'accessing' }
FamixJavaSourceAnchorSE >> sourceText [

	^ customSourceText 
]
