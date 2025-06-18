"
A service extrator. It takes a famix method and give all (available at static time) entities needed to execute that service.
"
Class {
	#name : 'ServiceExtractor',
	#superclass : 'Object',
	#instVars : [
		'callGraph',
		'classes',
		'extractPath',
		'methodsToExtract'
	],
	#category : 'Service-Extractor-Extractor',
	#package : 'Service-Extractor',
	#tag : 'Extractor'
}

{ #category : 'extraction' }
ServiceExtractor class >> extractMethod: aMethod [

	^ self new
		  extractMethods: {aMethod}
]

{ #category : 'extraction' }
ServiceExtractor class >> extractMethods: aCollectionOfMethods [

	^ self new
		  extractMethods: aCollectionOfMethods
]

{ #category : 'extraction' }
ServiceExtractor >> attributesUsedBy: aMethod [

	| dependencies attributes |
	dependencies := Set new.
	attributes := (aMethod accesses
		               collect: #variable
		               thenSelect: [ :var |
		               var isStub not and: [ var isAttribute ] ]) asSet.
	"attributes do: [ :att |
		dependencies add: att.
		att incomingAccesses do: [ :access |
			access isWrite ifTrue: [ dependencies add: access accessor ] ] ]."
	^ attributes
]

{ #category : 'accessing' }
ServiceExtractor >> classes [

	^ classes
]

{ #category : 'extraction' }
ServiceExtractor >> collectDependenciesOf: aClass in: classDict [

	aClass ifNil: [ ^ self ].
	aClass isPrimitiveType ifTrue: [ ^ self ].
	"Before checking if the parametric class is stub, we need to look at parameters."
	aClass isParametricEntity ifTrue: [
		aClass concreteParameters do: [ :cp |
			self collectDependenciesOf: cp in: classDict ] ].

	"If it is stub we just import."
	aClass isStub ifTrue: [ ^ self ].
	classDict at: aClass ifPresent: [ ^ self ].
	classDict at: aClass ifAbsentPut: [ Set new ].

	"(aClass attributes collect: [ :a | a declaredType ]) do: [ :t |
		self collectDependenciesOf: t in: classDict ]."

	"(aClass methods collect: [ :m | m declaredType ]) do: [ :t |
		self collectDependenciesOf: t in: classDict ]."
	"(aClass methods flatCollect: [ :m |
		 m parameters , m localVariables collect: [ :p | p declaredType ] ])
		do: [ :t | self collectDependenciesOf: t in: classDict ]."

	"(aClass methods flatCollect: [ :m |
		 m outgoingReferences collect: [ :r | r referredType ] ]) do: [ :t |
		self collectDependenciesOf: t in: classDict ]"
]

{ #category : 'extraction' }
ServiceExtractor >> dependenciesOf: aMethod [

	| dependencies attributes |
	dependencies := Set new.
	attributes := (aMethod accesses
		               collect: #variable
		               thenSelect: [ :var | var isAttribute ]) asSet.
	"attributes do: [ :att |
		dependencies add: att.
		att incomingAccesses do: [ :access |
			access isWrite ifTrue: [ dependencies add: access accessor ] ] ]."
	^ attributes
]

{ #category : 'extraction' }
ServiceExtractor >> extract [

	^ self extractFromCallGraph
]

{ #category : 'extraction' }
ServiceExtractor >> extractCHA [

	^ self extractFromCallGraphCHA
]

{ #category : 'extraction' }
ServiceExtractor >> extractClass: aClass [

	^ self extractClasses: aClass asCollection
]

{ #category : 'extraction' }
ServiceExtractor >> extractClasses: classesToExtract [

	^ self extractMethods: (classesToExtract flatCollect: [ :c | c methods ]).
	
]

{ #category : 'extraction' }
ServiceExtractor >> extractCode [

	FAMIX2JavaVisitor new
		slicedClasses: classes;
		rootFolder: self extractPath asFileReference;
		export: methodsToExtract anyOne mooseModel
]

{ #category : 'extraction' }
ServiceExtractor >> extractConfigurationFiles [

	| rec rac |
	rec := XMLSpringReconfigurator new.
	rec classDict: classes.
	rec mooseModel: methodsToExtract anyOne mooseModel.
	rec exportFiles.
	rec generateFilesAt: self extractPath.
	

	rac := XMLHibernateReconfigurator new. 
	rac classDict: classes.
	rac mooseModel: methodsToExtract anyOne mooseModel.
	rac exportFiles.
	rac generateFilesAt: self extractPath
]

{ #category : 'extraction' }
ServiceExtractor >> extractFromCallGraph [

	| cgMethods  cgm |
	cgm := JavaCallGraphModel new
		       entryMethods: {self methodToExtract}.
	callGraph := self methodToExtract callGraph.

	classes := Dictionary new.
	cgMethods := Set with: methodsToExtract.
	cgMethods addAll:
		(callGraph associations flatCollectAsSet: [ :a | a value ]).

	cgMethods do: [ :m |
		| class attributes localVariables |
		class := m parentType.
		localVariables := m localVariables asOrderedCollection
		                  , m parameters asOrderedCollection.
		attributes := self attributesUsedBy: m.
		localVariables , attributes asOrderedCollection do: [ :lv |
			| lvType |
			lvType := lv declaredType.
			(lvType notNil and: [ lvType isStub not ]) ifTrue: [
				classes at: lvType ifAbsentPut: [ Set new ] ].
			(lvType notNil and: [ lvType isParametricEntity ]) ifTrue: [
				lvType concreteParameters do: [ :cp |
					cp isStub ifFalse: [ classes at: cp ifAbsentPut: [ Set new ] ] ] ] ].


		classes
			at: class
			ifPresent: [ :entities | entities addAll: attributes ]
			ifAbsentPut: [ Set withAll: attributes ].
		(classes at: class) add: m.
		attributes do: [ :a |
			a incomingAccesses do: [ :access |
				(access isWrite and: [ access accessor name = '<Initializer>' ])
					ifTrue: [ (classes at: class) add: access accessor ] ] ] ].

	classes keysDo: [ :c |
		(c superclassHierarchy reject: #isStub) do: [ :sc |
			classes at: sc put: Set new ] ].


	classes keysDo: [ :c |
		(classes at: c) ifNotEmpty: [
			c methods do: [ :m |
				m isConstructor ifTrue: [ (classes at: c) add: m ] ] ] ].

	classes valuesDo: [ :v |
		v do: [ :e |
			((e isAttribute or: [ e isMethod ]) and: [
				 e declaredType isClass and: [ e declaredType isStub not ] ])
				ifTrue: [ classes at: e declaredType ifAbsentPut: [ Set new ] ] ] ].

	^ classes
]

{ #category : 'extraction' }
ServiceExtractor >> extractFromCallGraphCHA [

	| cgMethods |
	callGraph := uccg callGraphOfMethods: self methodsToExtract.

	cgMethods := Set withAll: methodsToExtract.
	cgMethods addAll:
		(callGraph associations flatCollectAsSet: [ :a | a value ]).

	cgMethods do: [ :m |
		| class attributes localVariables |
		class := m parentType.
		localVariables := m localVariables asOrderedCollection
		                  , m parameters asOrderedCollection.
		attributes := self attributesUsedBy: m.
		localVariables , attributes asOrderedCollection do: [ :lv |
			| lvType |
			(lv isAttribute and: [ lv parentType ~= class ]) ifTrue: [
				classes
					at: lv parentType
					ifPresent: [ :entities | entities add: lv ]
					ifAbsentPut: [ Set with: lv ] ].
			lvType := lv declaredType.
			self collectDependenciesOf: lvType in: classes ].

		m parentType isClass ifTrue: [
			m overriddenMethod ifNotNil: [
				classes
					at: m overriddenMethod parentType
					ifPresent: [ :entities | entities add: m overriddenMethod ]
					ifAbsentPut: [ Set with: m overriddenMethod ] ] ].

		classes
			at: class
			ifPresent: [ :entities | entities addAll: attributes ]
			ifAbsentPut: [ Set withAll: attributes ].
		(classes at: class) add: m.
		attributes do: [ :a |
			a incomingAccesses do: [ :access |
				(access isWrite and: [ access accessor name = '<Initializer>' ])
					ifTrue: [ (classes at: class) add: access accessor ] ] ].

		(m allExceptions reject: #isStub) do: [ :exception |
			classes at: exception ifAbsentPut: [ Set new ] ] ].


	"cgm stubMethods do: [ :sm |
		sm receiver ifNotNil: [:r | |cla|
			cla := r isClass ifTrue: [ r ] ifFalse: [ r declaredType ].
			cla allSubclassesAndImplementations do: [ :ci |
			classes at: ci ifAbsentPut: Set new ] ]]."

	classes keysDo: [ :c |
		(classes at: c) ifNotEmpty: [
			c methods do: [ :m |
				m isConstructor ifTrue: [ (classes at: c) add: m ] ] ] ].


	classes valuesDo: [ :v |
		v do: [ :e |
			((e isAttribute or: [ e isMethod ]) and: [
				 e declaredType isClass and: [ e declaredType isStub not ] ])
				ifTrue: [ classes at: e declaredType ifAbsentPut: [ Set new ] ] ] ].

	classes keysDo: [ :c |
		(c superclassHierarchy reject: #isStub) do: [ :sc |
			classes at: sc ifAbsentPut: Set new ] ].
	
	classes keys do: [ :k | k isStub ifTrue: [ classes removeKey: k ] ].
	^ classes
]

{ #category : 'extraction' }
ServiceExtractor >> extractMethods: aCollectionOfMethods [

	self methodsToExtract: aCollectionOfMethods.
	^ self extractCHA
]

{ #category : 'accessing' }
ServiceExtractor >> extractPath [

	^ extractPath, '/', methodsToExtract anyOne name
]

{ #category : 'accessing' }
ServiceExtractor >> extractPath: anObject [

	extractPath := anObject
]

{ #category : 'extraction' }
ServiceExtractor >> initialize [

	super initialize.
	classes := Dictionary new.
]

{ #category : 'accessing' }
ServiceExtractor >> methodsToExtract [

	^ methodsToExtract
]

{ #category : 'accessing' }
ServiceExtractor >> methodsToExtract: anObject [

	methodsToExtract := anObject
]
