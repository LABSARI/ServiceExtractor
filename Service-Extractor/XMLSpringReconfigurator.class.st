Class {
	#name : 'XMLSpringReconfigurator',
	#superclass : 'XMLNodeVisitor',
	#instVars : [
		'beans',
		'xmlReferences',
		'xmlDocuments',
		'classDict',
		'refDict',
		'javaSprintDetector',
		'mooseModel',
		'tBeans'
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

	| id class aLink classPath |
	id := aBean attributeAt: 'id'.
	classPath := aBean attributeAt: 'class'.

	aLink := javaSprintDetector detectedLinks
		         detect: [ :al | al referenceEntity elementName = classPath ]
		         ifNone: [
			         refDict at: id put: nil.
			         ^ self ].
	class := aLink resourceEntity element.
	refDict at: id put: class.

	(classDict includesKey: class) ifFalse: [
		aBean removeFromParent.
		 ] ifTrue: [ 
		tBeans add: aBean
		 ]
]

{ #category : 'visiting' }
XMLSpringReconfigurator >> deleteUnusedBeans [

	beans do: [ :bean | self deleteBeanIfUnused: bean ]
]

{ #category : 'processing' }
XMLSpringReconfigurator >> detectAllLinks [

	| links files |
	javaSprintDetector := AdonisSpring new.
	javaSprintDetector mainModel: mooseModel.
	javaSprintDetector detectAllLinks.

	links := javaSprintDetector detectedLinks.
	files := links collectAsSet: [ :al | al referenceEntity path ].
	xmlReferences := (files collect: [ :f | f asFileReference ])
		                 asOrderedCollection
]

{ #category : 'visiting' }
XMLSpringReconfigurator >> exportFiles [
	
	refDict := Dictionary new.
	tBeans := OrderedCollection new.
	self detectAllLinks.
	self collectBeans.
	self deleteUnusedBeans.
	1halt.
]

{ #category : 'accessing' }
XMLSpringReconfigurator >> mooseModel: anObject [

	mooseModel := anObject
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
