// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/ast.dart';
import 'package:pigeon/java_generator.dart';
import 'package:test/test.dart';

void main() {
  test('gen one class', () {
    final Class klass = Class(
      name: 'Foobar',
      fields: <Field>[
        Field(
          name: 'field1',
          dataType: 'int',
        ),
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[klass],
    );
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public class Messages'));
    expect(code, contains('public static class Foobar'));
    expect(code, contains('private Long field1;'));
  });

  test('package', () {
    final Class klass = Class(
      name: 'Foobar',
      fields: <Field>[
        Field(
          name: 'field1',
          dataType: 'int',
        )
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[klass],
    );
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions(className: 'Messages')
      ..package = 'com.google.foobar';
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('package com.google.foobar;'));
    expect(code, contains('Map<String, Object> toMap()'));
  });

  test('gen one host api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'Input',
          returnType: 'Output',
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(
          name: 'Input',
          fields: <Field>[Field(name: 'input', dataType: 'String')]),
      Class(
          name: 'Output',
          fields: <Field>[Field(name: 'output', dataType: 'String')])
    ]);
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public interface Api'));
    expect(code, matches('Output.*doSomething.*Input'));
    expect(code, contains('channel.setMessageHandler(null)'));
  });

  test('all the simple datatypes header', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(name: 'Foobar', fields: <Field>[
        Field(name: 'aBool', dataType: 'bool'),
        Field(name: 'aInt', dataType: 'int'),
        Field(name: 'aDouble', dataType: 'double'),
        Field(name: 'aString', dataType: 'String'),
        Field(name: 'aUint8List', dataType: 'Uint8List'),
        Field(name: 'aInt32List', dataType: 'Int32List'),
        Field(name: 'aInt64List', dataType: 'Int64List'),
        Field(name: 'aFloat64List', dataType: 'Float64List'),
      ]),
    ]);

    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('private Boolean aBool;'));
    expect(code, contains('private Long aInt;'));
    expect(code, contains('private Double aDouble;'));
    expect(code, contains('private String aString;'));
    expect(code, contains('private byte[] aUint8List;'));
    expect(code, contains('private int[] aInt32List;'));
    expect(code, contains('private long[] aInt64List;'));
    expect(code, contains('private double[] aFloat64List;'));
  });

  test('gen one flutter api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'Input',
          returnType: 'Output',
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(
          name: 'Input',
          fields: <Field>[Field(name: 'input', dataType: 'String')]),
      Class(
          name: 'Output',
          fields: <Field>[Field(name: 'output', dataType: 'String')])
    ]);
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public static class Api'));
    expect(code, matches('doSomething.*Input.*Output'));
  });

  test('gen host void api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'Input',
          returnType: 'void',
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(
          name: 'Input',
          fields: <Field>[Field(name: 'input', dataType: 'String')]),
    ]);
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, isNot(matches('=.*doSomething')));
    expect(code, contains('doSomething('));
  });

  test('gen flutter void return api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'Input',
          returnType: 'void',
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(
          name: 'Input',
          fields: <Field>[Field(name: 'input', dataType: 'String')]),
    ]);
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('Reply<Void>'));
    expect(code, isNot(contains('.fromMap(')));
    expect(code, contains('callback.reply(null)'));
  });

  test('gen host void argument api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'void',
          returnType: 'Output',
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(
          name: 'Output',
          fields: <Field>[Field(name: 'output', dataType: 'String')]),
    ]);
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('Output doSomething()'));
    expect(code, contains('api.doSomething()'));
  });

  test('gen flutter void argument api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'void',
          returnType: 'Output',
          isAsynchronous: false,
        )
      ])
    ], classes: <Class>[
      Class(
          name: 'Output',
          fields: <Field>[Field(name: 'output', dataType: 'String')]),
    ]);
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('doSomething(Reply<Output>'));
    expect(code, contains('channel.send(null'));
  });

  test('gen list', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(
          name: 'Foobar',
          fields: <Field>[Field(name: 'field1', dataType: 'List')]),
    ]);
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public static class Foobar'));
    expect(code, contains('private List<Object> field1;'));
  });

  test('gen map', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[
      Class(
          name: 'Foobar',
          fields: <Field>[Field(name: 'field1', dataType: 'Map')]),
    ]);
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public static class Foobar'));
    expect(code, contains('private Map<Object, Object> field1;'));
  });

  test('gen nested', () {
    final Class klass = Class(
      name: 'Outer',
      fields: <Field>[
        Field(
          name: 'nested',
          dataType: 'Nested',
        )
      ],
    );
    final Class nestedClass = Class(
      name: 'Nested',
      fields: <Field>[
        Field(
          name: 'data',
          dataType: 'int',
        )
      ],
    );
    final Root root = Root(
      apis: <Api>[],
      classes: <Class>[klass, nestedClass],
    );
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public class Messages'));
    expect(code, contains('public static class Outer'));
    expect(code, contains('public static class Nested'));
    expect(code, contains('private Nested nested;'));
    expect(code, contains('Nested.fromMap((Map)nested);'));
    expect(code, contains('put("nested", nested.toMap());'));
  });

  test('gen one async Host Api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.host, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'Input',
          returnType: 'Output',
          isAsynchronous: true,
        )
      ])
    ], classes: <Class>[
      Class(
          name: 'Input',
          fields: <Field>[Field(name: 'input', dataType: 'String')]),
      Class(
          name: 'Output',
          fields: <Field>[Field(name: 'output', dataType: 'String')])
    ]);
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public interface Api'));
    expect(code, contains('public interface Result<T> {'));
    expect(
        code, contains('void doSomething(Input arg, Result<Output> result);'));
    expect(
        code,
        contains(
            'api.doSomething(input, result -> { wrapped.put("result", result.toMap()); reply.reply(wrapped); });'));
    expect(code, contains('channel.setMessageHandler(null)'));
  });

  test('gen one async Flutter Api', () {
    final Root root = Root(apis: <Api>[
      Api(name: 'Api', location: ApiLocation.flutter, methods: <Method>[
        Method(
          name: 'doSomething',
          argType: 'Input',
          returnType: 'Output',
          isAsynchronous: true,
        )
      ])
    ], classes: <Class>[
      Class(
          name: 'Input',
          fields: <Field>[Field(name: 'input', dataType: 'String')]),
      Class(
          name: 'Output',
          fields: <Field>[Field(name: 'output', dataType: 'String')])
    ]);
    final StringBuffer sink = StringBuffer();
    final JavaOptions javaOptions = JavaOptions(className: 'Messages');
    generateJava(javaOptions, root, sink);
    final String code = sink.toString();
    expect(code, contains('public static class Api'));
    expect(code, matches('doSomething.*Input.*Output'));
  });
}
