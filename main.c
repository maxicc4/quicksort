#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <getopt.h>

#ifndef VERSION
#define VERSION "1.0"
#endif

#ifndef no_argument
#define no_argument 0
#endif

#ifndef required_argument
#define required_argument 1
#endif

#ifndef optional_argument
#define optional_argument 2
#endif

/*
 * Parámetros globales.
 */

FILE *output = NULL;
char *inputName = "";
int numeric = 0;

static void parse_cmdline(int, char * const []);
static void read_file(char *fileName, char ***izq, char ***der);
static void do_usage(const char *, int);
static void do_version(const char *);
static void do_output(const char *, const char *);

int
main(int argc, char * const argv[], char * const envp[])
{
	char **izq = NULL;
	char **der = NULL;
	parse_cmdline(argc, argv);
	read_file(inputName, &izq, &der);
	//TODO: llamar a quicksort

	// Se libera la memoria que se reservo al leer las lineas del archivo
	for (char** x=izq; x<=der; x++) {
		printf("---%s\n", *x);
		free(*x);
	}
	free(izq);

	return 0;
}

static void
read_file(char *fileName, char ***izq, char ***der)
{
	FILE *input;
	char line[800];
	char **first = NULL;
	char **last = NULL;

	if (!(input = fopen(fileName, "r"))) {
		fprintf(stderr, "cannot open input file.\n");
		exit(1);
	}

	int i=0;
	while (fgets(line, sizeof(line), input) != NULL) {
		// Se sacan los caracteres de fin de linea para que no molesten
		// al querer guardarlos denuevo en un archivo
		line[strcspn(line, "\f\r\n")] = 0;

		first = (char **)realloc(first, (i+1)*sizeof(char**));
		first[i] = (char*)malloc(sizeof(line));
		strcpy(first[i], line);

		i++;
	}

	if (first) {
		last = &(first[i-1]);
	}
	*izq = first;
	*der = last;

	fclose(input);
}

static void
parse_cmdline(int argc, char * const argv[])
{
	int ch;
	int index = 0;

	struct option options[] = {
		{"help", no_argument, NULL, 'h'},
		{"version", no_argument, NULL, 'V'},
		{"numeric", no_argument, NULL, 'n'},
		{"output", required_argument, NULL, 'o'},
	};

	while ((ch = getopt_long(argc, argv, 
	                         "ho:nV", options, &index)) != -1) {
		switch (ch) {
		case 'h':
			do_usage(argv[0], 0);
			break;
		case 'V':
			do_version(argv[0]);
			break;
		case 'o':
			do_output(argv[0], optarg);
			break;
		case 'n':
			numeric = 1;
			break;
		default:
			do_usage(argv[0], 1);
		}
	}

	if (output == NULL)
		output = stdout;

	if (optind < argc) {
		inputName = argv[optind++];
	} else {
		do_usage(argv[0], 1);
	}
}

static void
do_usage(const char *name, int status)
{
	fprintf(stderr, "Usage:\n");
	fprintf(stderr, "  %s -h\n", name);
	fprintf(stderr, "  %s -V\n", name);
	fprintf(stderr, "  %s [options] archivo\n", name);
	fprintf(stderr, "Options:\n");
	fprintf(stderr, "  -h, --help "
	                " Imprime ayuda.\n");
	fprintf(stderr, "  -V, --version "
	                " Version del programa.\n");
	fprintf(stderr, "  -o, --output "
	                " Archivo de salida.\n");
	fprintf(stderr, "  -n, --numeric "
	                " Ordenar los datos numericamente en vez de alfabeticamente.\n");
	fprintf(stderr, "Examples:\n");
	fprintf(stderr, "  %s -n numeros.txt\n", name);
	exit(status);
}

static void
do_version(const char *name)
{
	fprintf(stderr, "%s\n", VERSION);
	exit(0);
}

static void
do_output(const char *name, const char *spec)
{
	if (output != NULL) {
		fprintf(stderr, "multiple do output files.\n");
		exit(1);
	}

	if (strcmp(spec, "-") == 0) {
		output = stdout;
	} else {
		if (!(output = fopen(spec, "w"))) {
			fprintf(stderr, "cannot open output file.\n");
			exit(1);
		}
	}
}
