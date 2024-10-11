Class {
	#name : 'JavaCallGraphModel',
	#superclass : 'Object',
	#instVars : [
		'callGraph',
		'classes',
		'methods',
		'typeGraph',
		'entryMethod',
		'nodesDict',
		'stubMethods'
	],
	#category : 'Service-Extractor',
	#package : 'Service-Extractor'
}

{ #category : 'as yet unclassified' }
JavaCallGraphModel class >> chaFromMethod: aMethod [

	^ self new
		  entryMethod: aMethod;
		  cha
]

{ #category : 'as yet unclassified' }
JavaCallGraphModel class >> vtaFromMethod: aMethod [

	^ self new
		  entryMethod: aMethod;
		  buildtypeGraph
]

{ #category : 'initialization' }
JavaCallGraphModel >> addLinkFrom: m1 to: m2 [

	methods
		add: m1;
		add: m2.
	callGraph
		at: m1
		ifPresent: [ :list | list add: m2 ]
		ifAbsentPut: [ Set with: m2 ]
]

{ #category : 'accessing' }
JavaCallGraphModel >> buildNodeFor: v [


	^ TypeGraphNode  new
		  label: v callGraphLabel;
		  famixEntity: v;
		  yourself
]

{ #category : 'accessing' }
JavaCallGraphModel >> buildtypeGraph [

	typeGraph := Dictionary new.
	nodesDict := Dictionary new.
	"Create nodes for the type graph."
	classes do: [ :c |
		c attributes do: [ :a |
			a hasObjectType ifTrue: [ nodesDict at: a callGraphLabel put: a ] ] ].

	methods do: [ :m |
		m parameters , m localVariables , m implicitVariables do: [ :p |
			p hasObjectType ifTrue: [ nodesDict at: p callGraphLabel put: p ] ].

		m hasReturnObjectType ifTrue: [
			nodesDict at: m returnCallGraphLabel put: m declaredType ] ].
	"Add egdes to the type graph."
	methods do: [ :m |
		| ast |
		ast := (JavaSmaCCProgramNodeImporterVisitor new
			        parseCodeMethodString: m sourceText)
			       allFASTJavaMethodEntity first.
		"Assignment statements: a = b or a = (C) b"
		((ast allToScope: FASTJavaAssignementExpression)
		 , (ast allToScope: FASTJavaVariableDeclarator) select: [ :a |
			 a expression class = FASTJavaVariableExpression or: [
				 a expression class = FASTJavaCastExpression and: [
					 a expression expression class = FASTJavaVariableExpression ] ] ])
			do: [ :fa |
				| var expVar famixVar famixExpVar |
				var := fa variable.
				expVar := fa expression.
				expVar class = FASTJavaCastExpression ifTrue: [
					expVar := expVar expression ].
				famixVar := self findFamixVariable: var from: m.
				famixExpVar := self findFamixVariable: expVar from: m.
				typeGraph
					at: famixExpVar
					ifPresent: [ :c | c add: famixVar ]
					ifAbsentPut: [ OrderedCollection with: famixVar ] ] ]. 
]

{ #category : 'accessing' }
JavaCallGraphModel >> callGraph [

	^ callGraph ifNil: [
		  | dict |
		  dict := Dictionary new.
		  dict at: entryMethod put: 0.
		  classes add: entryMethod parentType.
		  methods add: entryMethod.
		  self callGraph: dict depth: 0 method: entryMethod.
		  callGraph := dict ]
]

{ #category : 'computing' }
JavaCallGraphModel >> callGraph: dict depth: depth method: aMethod [

	| providers newDepth methodsToExplore |
	newDepth := depth + 1.
	providers := ((aMethod queryOutgoing: FamixTInvocation)
		              flatCollect: #allTargets) reject: #isStub.
	methodsToExplore := Set new.
	
	providers do: [ :m |
		methodsToExplore add: m.
		m parentType isParameterizedType ifFalse: [
			methodsToExplore addAll: m overridingMethods ] ].
	
	methodsToExplore do: [ :m |
		(dict includesKey: m) ifFalse: [
			dict at: m put: newDepth.
			classes add: m declaredType.
			methods add: m.
			self callGraph: dict depth: newDepth method: m] ].
	
	^ dict
]

{ #category : 'initialization' }
JavaCallGraphModel >> cha [

	| worklist |
	callGraph := Dictionary new.
	stubMethods := OrderedCollection new.
	worklist := LinkedList new.

	worklist add: entryMethod.

	[ worklist isEmpty ] whileFalse: [
		| calls workMethod |
		workMethod := worklist removeLast.

		calls := workMethod queryOutgoing: FamixTInvocation.
		calls do: [ :call |
			| method overridingMethods |
			call candidates ifNotEmpty: [
				method := call candidates first.

				overridingMethods := OrderedCollection new.
				(method isStub not and: [ method numberOfStatements > 0 ])
					ifTrue: [ overridingMethods add: method ].
				overridingMethods addAll: (method overridingMethods reject: #isStub).
				method isStub ifTrue: [ stubMethods add: call ].
				overridingMethods do: [ :oMeth |
					self addLinkFrom: workMethod to: oMeth.
					(callGraph includesKey: oMeth) ifFalse: [ worklist add: oMeth ] ] ] ] ].
	classes := methods collectAsSet: [ :m | m parentType ].
	^ callGraph
]

{ #category : 'accessing' }
JavaCallGraphModel >> entryMethod [

	^ entryMethod
]

{ #category : 'accessing' }
JavaCallGraphModel >> entryMethod: anObject [

	entryMethod := anObject
]

{ #category : 'private utils' }
JavaCallGraphModel >> findFamixType: aFASTExpression from: aFamixJavaMethod [

	aFASTExpression class = FASTJavaFieldAccess ifTrue: [
		aFASTExpression receiver class = FASTJavaVariableExpression ifTrue: [
			^ self
				  findFamixType: aFASTExpression receiver
				  from: aFamixJavaMethod ].
		^ self findFamixType: aFASTExpression from: aFamixJavaMethod ].
	
	aFASTExpression class = FASTJavaVariableExpression ifTrue: [
		| var |
		var := self
			       findFamixVariable: aFASTExpression
			       from: aFamixJavaMethod.
		^ var isImplicitVariable
			  ifTrue: [ var parentBehaviouralEntity parentType ]
			  ifFalse: [ var declaredType ] ].
	AssertionFailure signal:
		'Could not handle: ' , aFASTExpression class asString
]

{ #category : 'private utils' }
JavaCallGraphModel >> findFamixVariable: aFASTNode from: aFamixJavaMethod [

	(aFASTNode class = FASTJavaClassProperty and: [ aFASTNode type name first isLowercase   ])ifTrue: [
		| type |
		type := self
			        findFamixType: aFASTNode type
			        from: aFamixJavaMethod.
		^ type attributes detect: [ :a | a name = aFASTNode fieldName ] ].
	
	aFASTNode class = FASTJavaFieldAccess ifTrue: [
		| type |
		type := self
			        findFamixType: aFASTNode receiver
			        from: aFamixJavaMethod.
		^ type attributes detect: [ :a | a name = aFASTNode fieldName ] ].

	aFASTNode class = FASTJavaVariableExpression ifTrue: [
		^ aFamixJavaMethod localVariables , aFamixJavaMethod parameters
		  , aFamixJavaMethod implicitVariables
			  detect: [ :lv |
				  lv name = aFASTNode name or: [
					  lv isImplicitVariable and: [
						  lv name = 'self' and: [ aFASTNode name = 'this' ] ] ] ]
			  ifNone: [
				  aFamixJavaMethod parentType attributes detect: [ :a |
					  a name = aFASTNode name ] ] ].
	AssertionFailure signal:
		'Could not handle: ' , aFASTNode class asString
]

{ #category : 'initialization' }
JavaCallGraphModel >> initialize [

	classes := Set new.
	methods := Set new
]

{ #category : 'accessing' }
JavaCallGraphModel >> stubMethods [

	^ stubMethods
]

{ #category : 'accessing' }
JavaCallGraphModel >> stubMethods: anObject [

	stubMethods := anObject
]
