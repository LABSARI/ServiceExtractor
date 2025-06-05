Class {
	#name : 'SpringControllerGenerator',
	#superclass : 'Object',
	#instVars : [
		'daoClass',
		'methods',
		'path',
		'model'
	],
	#category : 'Service-Extractor-Extractor',
	#package : 'Service-Extractor',
	#tag : 'Extractor'
}

{ #category : 'accessing' }
SpringControllerGenerator >> daoClass [

	^ daoClass
]

{ #category : 'accessing' }
SpringControllerGenerator >> daoClass: anObject [

	daoClass := anObject
]

{ #category : 'generating' }
SpringControllerGenerator >> declaredTypeFor: aType [

	^ String streamContents: [ :s |
			s << aType declaredType name.
			aType isParametricAssociation ifTrue: [
					s << '<'.
					(aType concretizations collect: [ :concretization | concretization typeArgument ])
						do: [ :concreteParameter |
								concreteParameter isParameterType
									ifTrue: [ s declaredTypeFor: concreteParameter ]
									ifFalse: [ s << concreteParameter name ] ]
						separatedBy: [ s << ',' ].
					s << '>' ] ]
]

{ #category : 'generating' }
SpringControllerGenerator >> generateClassController [

	| controllerClass controllerAnnotation controllerAnnotationInstance |
	controllerClass := FamixJavaClass named:  daoClass name, 'Controller.java' model: model.
	controllerAnnotation := FamixJavaAnnotationType new name: 'RestController'.
	controllerAnnotationInstance := FamixJavaAnnotationInstance new
		                          annotationType: controllerAnnotation.
	controllerClass annotationInstances add: controllerAnnotationInstance.
	self generateMethodsIn: controllerClass.
	^ controllerClass 
]

{ #category : 'generating' }
SpringControllerGenerator >> generateControllerFor: aClass [

	| p |
	daoClass := aClass.
	model := FamixJavaModel new.
	p := model newPackageNamed: 'p'.
	p addType: self generateClassController.
	FAMIX2JavaVisitor new
		rootFolder: FileSystem workingDirectory ;
		export: model. 
	
	
]

{ #category : 'generating' }
SpringControllerGenerator >> generateMethod: aMethod in: aControllerClass [

	| controllerMethod parameters sourceAnchor |
	controllerMethod := FamixJavaMethod named: aMethod name model: model.
	sourceAnchor := FamixJavaSourceAnchorSE new.
	sourceAnchor customSourceText: (self generateSourceTextFor: aMethod).
	parameters := aMethod parameters asOrderedCollection collect: #copy.
	
	controllerMethod
		parentType: aControllerClass;
		isPublic: true;
		"declaredType: (self generateDeclaredTypeFor: aMethod);"
		parameters: parameters;
		sourceAnchor: sourceAnchor.
		
]

{ #category : 'generating' }
SpringControllerGenerator >> generateMethodsIn: aControllerClass [

	daoClass methods do: [ :method |
		self generateMethod: method in: aControllerClass
		 ]
]

{ #category : 'generating' }
SpringControllerGenerator >> generateSourceTextFor: aMethod [

	^ '\{
		{1} {2} = {3}.{4};
		ResponseEntity.ok({2});
	\}' format: { 
		self declaredTypeFor: aMethod typing.
		self nameFor: aMethod typing.
		daoClass name asValidSelector.
		aMethod signature
	 }
]

{ #category : 'accessing' }
SpringControllerGenerator >> methods [

	^ methods
]

{ #category : 'accessing' }
SpringControllerGenerator >> methods: anObject [

	methods := anObject
]

{ #category : 'generating' }
SpringControllerGenerator >> nameFor: aTypingAssociation [

	^ aTypingAssociation declaredType name asValidSelector.
]

{ #category : 'accessing' }
SpringControllerGenerator >> path [

	^ path
]

{ #category : 'accessing' }
SpringControllerGenerator >> path: anObject [

	path := anObject
]
