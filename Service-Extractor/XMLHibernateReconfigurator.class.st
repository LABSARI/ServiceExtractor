Class {
	#name : 'XMLHibernateReconfigurator',
	#superclass : 'Object',
	#instVars : [
		'javaHQLDetector',
		'mooseModel',
		'xmlReferences',
		'classDict',
		'mappings',
		'tMappings'
	],
	#category : 'Service-Extractor-Extractor',
	#package : 'Service-Extractor',
	#tag : 'Extractor'
}

{ #category : 'accessing' }
XMLHibernateReconfigurator >> classDict [

	^ classDict
]

{ #category : 'accessing' }
XMLHibernateReconfigurator >> classDict: anObject [

	classDict := anObject
]

{ #category : 'as yet unclassified' }
XMLHibernateReconfigurator >> collectMappings [

	mappings := OrderedCollection new.
	javaHQLDetector detectedLinks do: [ :l |
		classDict at: l resourceEntity element ifPresent: [
			mappings add: l resourceEntity element
				-> (XMLDOMParser parse: l referenceEntity path asFileReference) ] ]
]

{ #category : 'visiting' }
XMLHibernateReconfigurator >> deleteProperties [

	tMappings := OrderedCollection new.
	mappings do: [ :m |
		| props c |
		c := m key.
		classDict at: c ifPresent: [ :elts |
			tMappings add: m.
			props := (m value allElements select: [ :n | n name = 'class' ])
				         first nodes select: [ :n |
				         n isElement and: [ n name ~= 'id' ] ].
			props do: [ :p |
				| attributeName |
				attributeName := p attributeAt: 'name'.
				elts
					detect: [ :e | e isAttribute and: [ e name = attributeName ] ]
					ifNone: [ p removeFromParent ] ] ] ]
]

{ #category : 'processing' }
XMLHibernateReconfigurator >> detectAllLinks [

	| links files |
	javaHQLDetector := AdonisJavaHQL new.
	javaHQLDetector mainModel: mooseModel.
	javaHQLDetector detectAllLinks.

	links := javaHQLDetector detectedLinks.
	files := links collectAsSet: [ :al | al referenceEntity path ].
	xmlReferences := (files collect: [ :f | f asFileReference ])
		                 asOrderedCollection
]

{ #category : 'visiting' }
XMLHibernateReconfigurator >> exportFiles [
	
	self detectAllLinks.
	self collectMappings.
	self deleteProperties
]

{ #category : 'accessing' }
XMLHibernateReconfigurator >> generateFilesAt: aPath [

	| fullPath |
	fullPath := aPath , '/hibernate'.
	tMappings do: [ :xdp |
		(fullPath , '/' , xdp key name , '.hbm.xml') asFileReference
			ensureCreateFile writeStreamDo: [ :stream |
			xdp value printOn: stream beforeWritingDo: [ :a |  ] ] ]
]

{ #category : 'accessing' }
XMLHibernateReconfigurator >> mooseModel: anObject [

	mooseModel := anObject
]
