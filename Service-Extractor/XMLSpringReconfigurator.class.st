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
		'tBeans',
		'xmlDocumentsPath'
	],
	#category : 'Service-Extractor-Extractor',
	#package : 'Service-Extractor',
	#tag : 'Extractor'
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
	xmlDocuments := OrderedCollection new.
	xmlDocumentsPath := OrderedCollection new.
	xmlReferences do: [ :xr |
		| doc |
		doc := XMLDOMParser parse: xr.
		xmlDocuments add: doc.
		xmlDocumentsPath add: xr basename -> doc ].
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
XMLSpringReconfigurator >> deleteDeadReferences [

	tBeans do: [ :b |
		(b nodes select: #isElement) do: [ :p |
			| att |
			att := p attributeAt: 'ref'.
			refDict
				at: att
				ifPresent: [ :class |
				classDict at: class ifAbsent: [ p removeFromParent ] ]
				ifAbsent: [ "let it like that" ] ] ]
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
	self deleteDeadReferences.
]

{ #category : 'visiting' }
XMLSpringReconfigurator >> generateFilesAt: aPath [

	| fullPath |
	fullPath := aPath , '/spring'.
	xmlDocumentsPath do: [ :xdp |
		(fullPath , '/' , xdp key) asFileReference ensureCreateFile writeStreamDo: [ :stream |
			xdp value printOn: stream beforeWritingDo: [ :a |  ] ] ]
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
