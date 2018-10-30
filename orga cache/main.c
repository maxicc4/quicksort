#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <sys/stat.h>
#include "Cache.h"

#ifndef VERSION
#define VERSION "1.0"
#endif

/*
 * Parametros globales.
 */

char *inputName = "";

static void parse_cmdline(int, char * const []);
static void process_file(char *fileName);
static void do_usage(const char *, int);
static void do_version(const char *);

int main(int argc, char * const argv[], char * const envp[])
{
	parse_cmdline(argc, argv);
	init();
	process_file(inputName);

	return 0;
}

static void process_file(char *fileName)
{
	FILE *input;
	char line[20];
	int address, value;
	char *token;

	if (!(input = fopen(fileName, "r"))) {
		fprintf(stderr, "cannot open input file.\n");
		exit(1);
	}
	struct stat stat_record;
	if(stat(fileName, &stat_record)) {
		fprintf(stderr, "cannot open input file.\n");
		exit(1);
	} else if(stat_record.st_size <= 1) {
		fprintf(stderr, "Error. Empty file.\n");
		exit(1);
	}
	int i=1;
	while (fgets(line, sizeof(line), input) != NULL) {
		// Se sacan los caracteres de fin de linea para que no molesten
		line[strcspn(line, "\f\r\n")] = 0;
		printf("%s:  ", line);
		token = strtok(line, " ");
		if (token == NULL) {
			fprintf(stderr, "Error al procesar el archivo en la linea %d.\n", i);
			exit(1);
		}

		if (strncmp(token, "W", 2) == 0) {
			token = strtok(NULL, ", ");
			if (token == NULL) {
				fprintf(stderr, "Error al procesar el archivo en la linea %d.\n", i);
				exit(1);
			}
			address = atoi(token);

			token = strtok(NULL, " ");
			if (token == NULL) {
				fprintf(stderr, "Error al procesar el archivo en la linea %d.\n", i);
				exit(1);
			}

			value = atoi(token);
			printf("%d", write_byte(address, value));
		} else if (strncmp(token, "R", 2) == 0) {
			token = strtok(NULL, " ");
			if (token == NULL) {
				fprintf(stderr, "Error al procesar el archivo en la linea %d.\n", i);
				exit(1);
			}
			address = atoi(token);
			printf("%d", read_byte(address));
		} else if (strncmp(token, "MR", 2) == 0) {
			printf("%d%%", get_miss_rate());
		} else {
			fprintf(stderr, "Error al procesar el archivo en la linea %d.\n", i);
			exit(1);
		}

		printf("\n");

		i++;
	}

	fclose(input);
}

static void parse_cmdline(int argc, char * const argv[])
{
	int ch;
	int index = 0;

	struct option options[] = {
		{"help", no_argument, NULL, 'h'},
		{"version", no_argument, NULL, 'V'},
	};

	while ((ch = getopt_long(argc, argv, 
	                         "hV", options, &index)) != -1) {
		switch (ch) {
		case 'h':
			do_usage(argv[0], 0);
			break;
		case 'V':
			do_version(argv[0]);
			break;
		default:
			do_usage(argv[0], 1);
		}
	}

	if (optind < argc) {
		inputName = argv[optind++];
	} else {
		do_usage(argv[0], 1);
	}
}

static void do_usage(const char *name, int status)
{
	fprintf(stderr, "Usage:\n");
	fprintf(stderr, "  %s -h\n", name);
	fprintf(stderr, "  %s -V\n", name);
	fprintf(stderr, "  %s archivo\n", name);
	fprintf(stderr, "Options:\n");
	fprintf(stderr, "  -h, --help "
	                " Imprime ayuda.\n");
	fprintf(stderr, "  -V, --version "
	                " Version del programa.\n");
	fprintf(stderr, "Examples:\n");
	fprintf(stderr, "  %s file.mem\n", name);
	exit(status);
}

static void do_version(const char *name)
{
	fprintf(stderr, "%s\n", VERSION);
	exit(0);
}
