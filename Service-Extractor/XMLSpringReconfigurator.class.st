Class {
	#name : 'XMLSpringReconfigurator',
	#superclass : 'XMLNodeVisitor',
	#instVars : [
		'beans',
		'xmlReferences',
		'xmlDocuments',
		'classDict',
		'refDict'
	],
	#category : 'Service-Extractor',
	#package : 'Service-Extractor'
}

{ #category : 'accessing' }
XMLSpringReconfigurator >> classDict [

	^ classDict
]

{ #category : 'accessing' }
XMLSpringReconfigurator >> classDict: anObject [

	classDict := anObject
]

{ #category : 'visiting' }
XMLSpringReconfigurator >> collectBeans [

	beans := OrderedCollection new.
	xmlDocuments := xmlReferences collect: [ :xr |
		                XMLDOMParser parse: xr ].
	xmlDocuments do: [ :doc | doc acceptNodeVisitor: self ]
]

{ #category : 'visiting' }
XMLSpringReconfigurator >> deleteBeanIfUnused: aBean [

	| id class |
	id := aBean attributes detect: [ :a | a name = 'id' ].
	class := aBean attributes detect: [ :a | a name = 'class' ].
	
	
]

{ #category : 'visiting' }
XMLSpringReconfigurator >> deleteUnusedBeans [

	beans do: [ :bean | self deleteBeanIfUnused: bean ]
]

{ #category : 'visiting' }
XMLSpringReconfigurator >> visitDocument: aXMLDocument [

	super visitDocument: aXMLDocument.
]

{ #category : 'visiting' }
XMLSpringReconfigurator >> visitElement: aXMLElement [

	aXMLElement name = 'bean' ifTrue: [ beans add: aXMLElement ].
	super visitElement: aXMLElement
]

{ #category : 'accessing' }
XMLSpringReconfigurator >> xmlReferences [

	^ xmlReferences
]

{ #category : 'accessing' }
XMLSpringReconfigurator >> xmlReferences: anObject [

	xmlReferences := anObject
]
